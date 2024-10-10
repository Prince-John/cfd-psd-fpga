#
# Added by gle on 17-Sep-2024 
# Suppresses warnings about missing board files
# We don't use board files so we don't care!!!

set_msg_config -suppress -id {Board 49-26} 

# Look at this more closely later

set_msg_config -suppress -id {Device 21-403} 
set_msg_config -suppress -id {Vivado 12-5825} 
set_msg_config -suppress -id {Vivado 12-7989} 
set_msg_config -suppress -id {Common 17-349} 

# Some synthesis stuff
# Look at this more closely later

set_msg_config -suppress -id {Synth 8-7079} 
set_msg_config -suppress -id {Synth 8-7078} 
set_msg_config -suppress -id {Synth 8-7075} 

# Suppress all warnings which just provide info

set_msg_config -suppress  -severity {INFO}

# Picoblaze 6 warnings
# It's fine, don't muck with it

set_msg_config -suppress -id {Synth 8-10294} 

