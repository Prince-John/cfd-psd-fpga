#
# Suppress warnings
#


set	mylist {


}

foreach item $myList {
	set		cmd 	"set_msg_config -suppress -id $item"
	{*}$cmd
}





