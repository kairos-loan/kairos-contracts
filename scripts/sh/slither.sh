REMAPS='@openzeppelin/=../../node_modules/@openzeppelin/ forge-std/=../../node_modules/forge-std/src/ ds-test/=../../node_modules/ds-test/src/ diamond/=../../node_modules/diamond/'

slither src \
	--solc-remaps "${REMAPS}" \
	--checklist \
	--exclude-dependencies \
  --exclude dead-code,solc-version,pragma \
	> out/slither-report.md

slither src \
	--solc-remaps "${REMAPS}" \
  --print function-summary \
  &> out/slither-functions-summary.txt

# slither src \
# 	--solc-remaps "${REMAPS}" \
#   --print cfg \
#   &> out/slither-functions-summary.txt
