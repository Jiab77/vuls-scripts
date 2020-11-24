#! /bin/sh -

if [ $# -eq 0 ]; then
	echo "specify [--redhat --amazon --debian --ubuntu --alpine]"
	exit 1
fi

target=$1
shift

case "$target" in
	--redhat) 
		goval-dictionary fetch-redhat ${@} 6 7 8 
		;;
	--amazon) 
		goval-dictionary fetch-amazon ${@} 
		;;
	--debian) 
		goval-dictionary fetch-debian ${@} 8 9 10
		;;
	--ubuntu) 
		goval-dictionary fetch-ubuntu ${@} 16 18 20
		;;
	--alpine) 
		goval-dictionary fetch-alpine ${@} 3.3 3.4 3.5 3.6 3.7 3.8 3.9 3.10 3.11
		;;
	--*)  echo "specify [--redhat --amazon --debian --ubuntu --alpine]"
		exit 1
		;;
	*) echo "specify [--redhat --amazon --debian --ubuntu --alpine]"
		exit 1
		;;
esac

exit 0
