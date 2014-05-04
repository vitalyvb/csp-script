#!/bin/bash

EXE="../test"
TMPVAL=`mktemp`

fail=0
success=0

function one_test(){
    local variant="$1"

    echo "#" $EXE "$f" $args  > "$TMPVAL"
    echo "" >> "$TMPVAL"
    $EXE "$f" $args 2> /dev/null | grep "^RESULT:" >> "$TMPVAL"

    if [ ! -f "$res" ]; then
	mv "$TMPVAL" "$res"
	echo " CREATE"
	continue;
    fi

    cmp "$res" "$TMPVAL" &> /dev/null

    if [ $? != 0 ]; then
	echo -n " $variant:FAIL"
	return 1
    fi
    echo -n " $variant:OK"
    return 0
}

for f in *.sc; do
    echo -n "Checking $f.... "

    args=`cat $f | awk '/^\/\/@/ { fn=$2; c=0; a=""; for (n=3;n<13 && $n!="";n++) {c++; a=a " " $n;}; printf("%s %s %s ", fn, c, a); }'`

    res="${f}.res"

    r=0

    one_test 1
    r=$[ $? | $r ]

    TEST_IO_MAX_SIZE=2 one_test 2
    r=$[ $? | $r ]

    echo ""
    if [ $r != 0 ]; then
	fail=$[ $fail + 1 ]
	continue;
    fi
    success=$[ $success + 1 ]
done

echo "Fail: $fail"
echo "Success: $success"

rm -f "$TMPVAL"

[ "$fail" == 0 ]
exit $?
