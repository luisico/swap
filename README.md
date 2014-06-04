Swap
=====

**Swap** is a VMD plugin that provides a set of procedures (no GUI is supplied) to swap coordinates between atoms in a molecule. The development of this plugin started due to the necessity to calculate the best rmsd between two conformations of a molecule that contains symmetric atoms. It has been further developed to allow for more abstract swapping of atoms and to be accessible from other plugins or the command line.

> Website: http://physiology.med.cornell.edu/faculty/hweinstein/vmdplugins/swap

## Installation

A small guide on how to install third party VMD plugins can be found [here](http://physiology.med.cornell.edu/faculty/hweinstein/vmdplugins/installation.html). In summary:

1. Create a VMD plugins' directory if you don't have one, ie */path/to/plugins/directory*.
2. Clone or download the project into a subdirectory of your *VMD plugins' directory* (ie. */path/to/plugins/directory/swap*):
```sh
cd /path/to/plugins/directory
git clone git_url swap
```
3. Add the following to your *$HOME/.vmdrc* file (if you followed the instructions in the link above, you might already have the first line present):
```tcl
set auto_path [linsert $auto_path 0 {/path/to/plugins/directory}]
```

## Getting started

Activate the (I suggest doing this in your *.vmdrc*, see installation instructions above):
```tcl
package require swap
```

Add/Remove equivalence definitions:
```tcl
::swap::list
::swap::add RES equiv {C1 C2 C3 C4}
::swap::list
::swap::list sym
::swap::list equiv
::swap::del RES
```

To calculate the best rmsd swapping *PHE* residues load two conformations of the same molecule in *mol 0* and *mol 1*. The effect will be more clear if you make sure some *PHE* residues have swapped conformations:
```tcl
set ref [atomselect 0 "resname PHE"]
set sel [atomselect 1 "resname PHE"]

# Calculate initial rmsd
set rmsd [measure rmsd $ref $sel]
puts "$rmsd"

# For each PHE residue, swap atoms and recalculate rmsd
foreach res [lsort -unique -integer [$sel get resid]] {
   set res_sel [atomselect 1 "resid $res"]
   ::swap::swap_residue $res_sel
   set rmsd2 [measure rmsd $ref $sel]
   puts -nonewline "$res $rmsd $rmsd2"
   # If new rmsd is lower, save it
   if {$rmsd2 < $rmsd} {
      lappend swapped $res_sel
      set rmsd $rmsd2
      puts -nonewline " -- swap"
   } else {
      # revert swap if rmsd was higher
      ::swap::swap_residue $res_sel
   }
   puts ""

   # Revert swaps of those residues that produces lower rmsd
   foreach r $swapped {
      ::swap::swap_residue $res_sel
   }
}
```

A more complex version of the previous example has been implemented in the [RMSDTT](http://physiology.med.cornell.edu/faculty/hweinstein/vmdplugins/rmsdtt) plugin, with support for trajectories. Another example to calculate the rmsd by residue using the swapping plugin can be found in [swapbyres.tcl](swapbyres.tcl).

## Reference

### ::swap::swap_list

`::swap::swap_list` is not a procedure, but an array that holds the definitions of atoms to swap for each residue. In addition, it holds a property called *type* that can be defined by the user to group set of equivalent atoms, i.e., symmetry atoms in PHE (sym), positions not well identified by XRAY in GLN (xray, or any other label you like to use). The following symmetry atoms are predifined:

```tcl
PHE {sym CD1 CD2 CE1 CE2}
TYR {sym CD1 CD2 CE1 CE2}
ASP {sym OD1 OD2}
GLU {sym OE1 OE2}
ARG {sym NH1 NH2}
VAL {sym CG1 CG2}
```

For example, *PHE* has type sym and defined *CD1* to be equivalent to *CD2*, and *CE1* to *CE2*.

### ::swap::list type

`::swap::list type` prints the definitions in `::swap::swap_list`.

If *type* is used only definitions of the corresponding type will be printed (see `::swap::swap_list` below for further explanations).

### ::swap::add resname type atoms o

`::swap::add resname type atoms o` adds a definition to `::swap::swap_list` for residue *resname*.

*atoms* is a list of pairs of equivalent atoms to swap the coordinates (enclose the list in brackets, see examples below). *o* can be set to 1 to force overwrite of definition. See `::swap::swap_list` below for further explanations.

### ::swap::del resname

`::swap::del resname` deletes the entry for residue *resname* in `::swap::swap_list`.

### ::swap::swap_residue res frame?

`::swap::swap_residue res frame?` will swap the atoms defined in the `::swap::swap_list` for the residue contained the in the atomselection *res* (must match to one single residue in the molecule). *frame* is an optional parameter to select the frame to use when swapping the coordinates (default: *now*).

### ::swap::swap_atoms atom1 atom2

`::swap::swap_atoms atom1 atom2` swap two atomselections (each must match to one single atom in the molecule). This proc is called from `::swap::swap_residue`.


## Author

Luis Gracia (https://github.com/luisico)

Developed at Weill Cornell Medical College

## Contributors

Please, use issues and pull requests for feedback and contributions to this project.

## License

See LICENSE.
