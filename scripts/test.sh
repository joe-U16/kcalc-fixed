#!/usr/bin/env bash

CALC_DEV=/dev/calc
CALC_MOD=calc.ko

EVAL=./eval

test_op() {
    echo $'\0'

    local expression=$1
    echo "Testing " ${expression} "..." 
    echo -ne ${expression}'\0' > $CALC_DEV
    $EVAL $(cat $CALC_DEV) $2
}

if [ "$EUID" -eq 0 ]
  then echo "Don't run this script as root"
  exit
fi

sudo rmmod -f calc 2>/dev/null
sleep 1

modinfo $CALC_MOD || exit 1
sudo insmod $CALC_MOD
sudo chmod 0666 $CALC_DEV
echo

# multiply
test_op '6*7' '42'

# add
test_op '1980+1' '1981'

# sub
test_op '2019-1' '2018'

# div
test_op '42/6' '7'
test_op '1/3' '0.333333'
test_op '1/3*6+2/4' '2.5'
test_op '(1/3)+(2/3)' '1'
test_op '(2145%31)+23' '29'
test_op '0/0' 'NAN_INT'# should be NAN_INT

# binary
test_op '(3%0)|0' '0' # should be 0
test_op '1+2<<3' '24' # should be (1 + 2) << 3 = 24
test_op '123&42' '42' # should be 42
test_op '123^42' '81' # should be 81

# parens
test_op '(((3)))*(1+(2))' '9' # should be 9

# assign
test_op 'x=5, x=(x!=0)' '1' # should be 1
test_op 'x=5, x = x+1' '1' # should be 6

# fancy variable name
test_op 'six=6, seven=7, six*seven' '42' # should be 42
test_op '小熊=6, 維尼=7, 小熊*維尼' '42' # should be 42
test_op 'τ=1.618, 3*τ' '4.854000' # should be 3 * 1.618 = 4.854
test_op '$(τ, 1.618), 3*τ()' '4.854' # shold be 3 * 1.618 = 4.854

# functions
test_op '$(zero), zero()' '0' # should be 0
test_op '$(one, 1), one()+one(1)+one(1, 2, 4)' '3' # should be 3
test_op '$(number, 1), $(number, 2+3), number()' '5' # should be 5

# pre-defined function
test_op 'nop()'

sudo rmmod calc

# epilogue
echo "Complete"
