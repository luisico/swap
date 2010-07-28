#
#             Swap atoms plugin
#
# Utility to swap coordinates between atoms.
#

# Author
# ------
#      Luis Gracia, PhD
#      Weill Medical College, Cornel University, NY
#      lug2002@med.cornell.edu

# Description
# -----------
# This utility will swap the coordinates between two atoms. It was developed
# as a workaround to find the lowest rmsd between two conformations of a
# molecule with symmetric atoms, i.e., PHE residues.

# Installation
# ------------
# To add this plugin to the VMD extensions menu you can either:
# a) add this to your .vmdrc:
#    source "/path/to/plugin/swap.tcl"

# swap.tcl
#    Main file.


package provide swap 1.0

namespace eval swap {
  variable swap_list

  # Format: residue_name equiv_label list_pair_atoms
  array unset swap_list
  array set swap_list {
    PHE {sym CD1 CD2 CE1 CE2}
    TYR {sym CD1 CD2 CE1 CE2}
    ASP {sym OD1 OD2}
    GLU {sym OE1 OE2}
    ARG {sym NH1 NH2}
    VAL {sym CG1 CG2}
  }
  
  proc add { resname type atoms {o 0} } {
    variable swap_list
    
    if {[lsearch [array names swap_list] $resname] >= 0 && $o == 0} {
      puts "Residue already exists. Use option \"o=1\" to overwrite"
      return
    }

    set swap_list($resname) "$type $atoms"
    return
  }

  proc del { resname } {
    variable swap_list
    
    unset swap_list($resname)
    return
  }

  proc list { {type "all"} } {
    variable swap_list

    if {$type == "all"} {
      parray swap_list
    } else {
      foreach r [array names swap_list] {
	if {[lindex $swap_list($r) 0] eq $type} {
	 puts "swap_list($r) = $swap_list($r)" 
	}
      }
    }
    
  }

  proc swap_residue { res {frame "now"} } {
    # residue is a VMD selection that matches to one residue only

    variable swap_list
    
    set residue [$res get residue]
    if {[llength [lsort -unique $residue]] > 1} {
      puts "Error: res contains more than 1 residue"
      return
    }

    set resname [lsort -unique [$res get resname]]
    set mol [$res molid]

    foreach {at1 at2} [lrange $swap_list($resname) 1 end] {
      #puts "$at1 --- $at2"
      swap_atoms [atomselect $mol "residue $residue and name $at1" frame $frame] [atomselect $mol "residue $residue and name $at2" frame $frame]
    }
  }  
  
  proc swap_atoms { atom1 atom2 } {
    # atom1 and atom2 are VMD selections that match to only one atom each
    
    if {[$atom1 num] > 1 || [$atom2 num] > 1} {
      puts "Error: atom1 or atom2 contained more than 1 atom"
      return
    }
    
    set xyz1 [$atom1 get {x y z}]
    $atom1 set {x y z} [$atom2 get {x y z}]
    $atom2 set {x y z} $xyz1
  }

  proc swap_order { atom1 atom2 } {
    # atom1 and atom2 are VMD selections that match to only one atom each
    
    if {[$atom1 num] > 1 || [$atom2 num] > 1} {
      puts "Error: atom1 or atom2 contained more than 1 atom"
      return
    }
    
    set keys {name type atomicnumber element resname altloc resid chain segname segid structure user radius mass charge beta occupancy}
    set temp [$atom1 get $keys]
    $atom1 set $keys [$atom2 get $keys]
    $atom2 set $keys $temp

    set keys {x y z ufx ufy ufz phi psi}
    for {set f 0} {$f < [molinfo [$atom1 molid] get numframes]} {incr f} {
      $atom1 frame $f
      $atom2 frame $f
      set temp [$atom1 get $keys]
      $atom1 set $keys [$atom2 get $keys]
      $atom2 set $keys $temp
    }
  }
}

