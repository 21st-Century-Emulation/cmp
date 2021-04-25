docker build -q -t cmp .
docker run --rm --name cmp -d -p 8080:8080 cmp

sleep 5

RESULT=`curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"abcd", "opcode":187,"state":{"a":10,"b":1,"c":66,"d":5,"e":5,"h":10,"l":2,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":true},"programCounter":1,"stackPointer":2,"cycles":0,"interruptsEnabled":true}}' \
  http://localhost:8080/api/v1/execute`
EXPECTED='{"id":"abcd", "opcode":187,"state":{"a":10,"b":1,"c":66,"d":5,"e":5,"h":10,"l":2,"flags":{"sign":false,"zero":false,"auxCarry":true,"parity":true,"carry":false},"programCounter":1,"stackPointer":2,"cycles":4,"interruptsEnabled":true}}'

docker kill cmp

DIFF=`diff <(jq -S . <<< "$RESULT") <(jq -S . <<< "$EXPECTED")`

if [ $? -eq 0 ]; then
    echo -e "\e[32mCMP Test Pass \e[0m"
    exit 0
else
    echo -e "\e[31mCMP Test Fail  \e[0m"
    echo "$RESULT"
    echo "$DIFF"
    exit -1
fi