if [[ "c[1-2]" =~ .*\[.*\].* ]]; then
    echo "good" 
else 
    echo "recheck 1st condition" 
fi

hostchar=$(echo "c1" | tr -cd '[:alpha:]')
if [[ $hostchar == $(echo "c[1-2]" | tr -cd '[:alpha:]') ]]; then
    echo "good"
else
    echo "recheck 2nd condition"
fi

if [[ "c[1-2]" == "*[*]*" && $hostchar == $(echo "c[1-2]" | tr -cd '[:alpha:]') ]]; then
    echo "good"
else
    echo "recheck total condition"
fi