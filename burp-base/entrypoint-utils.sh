#! /bin/bash

# change_parameter(): replace or append parameter on conf ifle
#
# $1 = configuration file
# $2 = parameter name
# $3 = parameter value

function change_parameter
{
	file="$1"
	name="$2"
	value="$3"

	line=0

	# if parameter name is postfixed by "_number", it's considered to be a parameter
	# which will appear multiple times (eg keep, include, etc).
	if [[ $name =~ (.*)_([[:digit:]]+)  ]]; then
		name=${BASH_REMATCH[1]}
		line=${BASH_REMATCH[2]}
	fi

  cfg_line="$name = $value"

	if [ "$name" == "password" ]; then
		echo "Setting password = ***"
	else
  	echo "Setting $cfg_line"
	fi

  if grep -q -E "^$name\s?=" $file; then

		# parameter found uncommented and line == 0 - replace existing conf
		if [ $line -eq 0 ]; then
	                awk "/^$name[[:space:]]?=/ { if (++cnt==1) print \"$cfg_line\" ; next }
        	                { print }" $file > $file.new && \
                	mv $file.new $file

		# line > 0 - append in correct position
		else
	                awk "{ print } ; /^$name[[:space:]]?=/ { if (++cnt==$line)
				{ print \"$cfg_line\" } }" $file > $file.new && \
        	        mv $file.new $file

		fi

        # Otherwise, if the parameter is found commented, replace the first match. Extra
        # commented values are kept.
        elif grep -q -E "^#\s?$name\s?=" $file; then


                awk "/^\#[[:space:]]?$name[[:space:]]?=/ { if (++cnt==1) { print \"$cfg_line\" ; next } }
                        { print }" $file > $file.new && \
                mv $file.new $file


        # parameter not found on the default config file; append
        else
                echo -e "$cfg_line" >> $file
        fi
}
