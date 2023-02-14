slither src \
	--solc-remaps '@openzeppelin/=../../node_modules/@openzeppelin/ forge-std/=../../node_modules/forge-std/src/ ds-test/=../../node_modules/ds-test/src/ diamond/=../../node_modules/diamond/' \
	--checklist \
	--exclude-dependencies \
  --exclude dead-code,solc-version,pragma \
	> slither-report.md