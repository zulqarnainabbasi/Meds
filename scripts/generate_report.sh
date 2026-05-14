#!/usr/bin/env bash

set -euo pipefail

mkdir -p output

REPORT="output/report.html"

cat << EOF > "$REPORT"
<!DOCTYPE html>
<html>
<head>
<title>RISC-V Report</title>
<style>
body {
    font-family: Arial;
    margin: 40px;
}
table {
    border-collapse: collapse;
    width: 60%;
}
th, td {
    border: 1px solid black;
    padding: 10px;
}
th {
    background-color: #ddd;
}
.pass {
    color: green;
}
.fail {
    color: red;
}
</style>
</head>
<body>

<h1>RISC-V Simulation Report</h1>

<table>
<tr>
<th>Log File</th>
<th>Status</th>
</tr>
EOF

for file in test_data/*.log; do
    if scripts/analyze.sh "$file" > /dev/null 2>&1; then
        STATUS="PASS"
        CLASS="pass"
    else
        STATUS="FAIL"
        CLASS="fail"
    fi

    cat << EOF >> "$REPORT"
<tr>
<td>$file</td>
<td class="$CLASS">$STATUS</td>
</tr>
EOF
done

cat << EOF >> "$REPORT"
</table>

</body>
</html>
EOF

echo "HTML report generated at $REPORT"