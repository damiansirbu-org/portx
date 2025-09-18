result=$(analyze_dependency)
echo "$result" | /c/App/Git/home/portx/packages/gojq/gojq.exe -r ".return_code"
