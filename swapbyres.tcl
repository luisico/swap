# Author: Luis Gracia
#      Weill Medical College, Cornel University, NY
#      lug2002@med.cornell.edu



# ref is the reference molecule
# mol is the target molecule
# start and end are the range of residues
# seltext is a selection command that is append to the residue, i.e, "sidechain"
# file is the filename for output
# swap turns on/off the swapping

package require swap
proc rms_by_res { {ref 0} {mol 0} {start 0} {end 0} {seltext ""} {file ""} {swap 1} } {
  array set resnames {
    ALA A ARG R ASN N ASP D CYS C
    GLU E GLN Q GLY G HIS H ILE I
    LEU L LYS K MET M PHE F PRO P
    SER S THR T TRP W TYR Y VAL V
  }

  if {$end == 0} {
    set end [lindex [lsort -integer -unique [[atomselect $ref "all"] get resid]] end]
  }

  set nframes [molinfo $mol get numframes]

  # RMSD by residue
  set sum_n 0
  for {set r $start} {$r <= $end} {incr r} {
    set text "resid $r"
    if {$seltext ne ""} {
      append text " and $seltext"
    }
    
    set ref_sel [atomselect $ref "$text"]
    set sel [atomselect $mol "$text"]
    set resname [lindex [lsort -unique [[atomselect $ref "resid $r"] get resname]] 0]
    set sum_n [expr $sum_n + [$sel num]]

    #puts "$r $resname: [$ref_sel get name] - [$sel get name]"
    append output [format "%4d %1s" $r $resnames($resname)]

    for {set f 0} {$f < $nframes} {incr f} {
      $sel frame $f
      if {$r == $start} {
	set rmstot($f) 0
      }
      if {[$ref_sel num] < 1 || [$sel num] < 1} {
	append output "    NA"
      } elseif {[$ref_sel num] == [$sel num]} {
	set rms [measure rmsd $ref_sel $sel]
	if {$swap == 1} {
	  switch -exact $resname {
	    ASP -
	    GLU -
	    ARG -
	    VAL -
	    TYR -
	    PHE {
	      ::swap::swap_residue $sel $f
	      set rms2 [measure rmsd $ref_sel $sel]
	      ::swap::swap_residue $sel $f
	      #puts "$rms $rms2"
	      if {$rms2 < $rms} {
		set rms $rms2
	      }
	    }
	  }
	}
	append output [format " %5.2f" $rms]
	set rmstot($f) [expr $rmstot($f) + $rms*$rms * [$sel num]]
      } else {
	append output "    NA"
      }
    }
    append output "\n"
  }
  
  
  set output1 [format "%4d %1s" 0 "0"]
  for {set f 0} {$f < $nframes} {incr f} {
    set rmstot($f) [expr sqrt($rmstot($f) / $sum_n)]
    append output1 [format " %5.2f" $rmstot($f)]
  }
  append output1 "\n"

  set output "$output1$output"


  if {$file eq ""} {
    puts -nonewline $output
  } else {
    set fid [open "$file" w]
    puts -nonewline $fid $output
    close $fid
  }
}
