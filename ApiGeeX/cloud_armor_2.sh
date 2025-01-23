export PREV_STATUS_CODE=
echo "waiting for hello-world to be accessible"
while :; do
    export STATUS_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" --max-time 5 -X GET "https://eval.example.com/hello-world")
    [[ "${STATUS_CODE}" == "${PREV_STATUS_CODE}" ]] || (
        echo
        echo "STATUS_CODE=${STATUS_CODE}"
    )
    export PREV_STATUS_CODE=${STATUS_CODE}
    [[ "${STATUS_CODE}" != "200" ]] || break
    echo -n "."
    sleep 5
done
echo
echo "***HELLO-WORLD IS ACCESSIBLE***"


curl -i -k "https://eval.example.com/hello-world"