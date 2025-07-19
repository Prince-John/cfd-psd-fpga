#
# Suppress warnings
#


set	errorList {
"{[Board 49-26]}"
"{[Vivado 12-818]}"
"{[Synth 8-10294]}"
"{[Synth 8-7071]}"
"{[Synth 8-7023]}"
"{[Synth 8-7080]}"
"{[Synth 8-3936]}"
"{[Synth 8-3332]}"
"{[Synth 8-6014]}"
"{[Synth 8-7129]}"
"{[Timing 38-316]}"
"{[Opt 31-1131]}"
"{[Power 33-332]}"
}

set		cmd 	"set_msg_config -suppress -severity INFO"
{*}$cmd

set		cmd 	"set_msg_config -suppress -severity STATUS"
{*}$cmd

foreach item $errorList {
	set		cmd 	"set_msg_config -suppress -id $item"
	{*}$cmd
#	puts $cmd
}





