 prType=${{ steps.pr.outputs.labels }}
          declare -A changedCharts

          for file in ${{ steps.changed-files.outputs.all_changed_and_modified_files }}; do         

              echo "$file was changed"
              baseFolder=$(cut -d'/' -f1 <<< "$file")
              if [ $baseFolder = "charts" ]; then
                  chartName=$(cut -d'/' -f2 <<< "$file")
                  changedCharts[$chartName]=$chartName
              fi  
          done    

          for c in "${changedCharts[@]}"; do
              # get version from chart yaml
              version=$(yq e '.version' "charts/$c/Chart.yaml")
              major=$(cut -d'.' -f1 <<< "$version")
              minor=$(cut -d'.' -f2 <<< "$version")
              patch=$(cut -d'.' -f3 <<< "$version")

              echo $prType
              if [ $prType="major" ]; then 
                  major=$((major+1))
                  minor=0
                  patch=0
              elif [ $prType="minor" ]; then
                  minor=$((minor+1))
                  patch=0
              elif [ $prType="patch" ]; then 
                  patch=$((patch+1))
              fi
              echo Update version to $major.$minor.$patch for $c
              yq e -i '.version = "'$major.$minor.$patch'"' charts/$c/Chart.yaml
          done