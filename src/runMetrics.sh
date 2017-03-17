#!/bin/bash

gpu=Tesla

declare -a apps=( lavaMD lud nw )

declare -A execApps
execApps["backprop"]="./backprop " 
execApps["gaussian"]="./gaussian " 
execApps["heartwall"]="./heartwall " 
execApps["hotspot"]="./hotspot " 
execApps["hotspot3D"]="./3D " 
execApps["lavaMD"]="././lavaMD " 
execApps["lud"]="./lud_cuda " 
execApps["nw"]="./needle " 
execApps["pathfinder"]="./pathfinder "

cd rodinia/cuda/

function saveTraces {		
    cat temp | awk -v var=$i '{print var"," $0}' | grep $gpu >> ../../../logs/${app}/${app}-metrics.csv    
}

for app in "${apps[@]}"; do 
    rm -rf ../../logs/${app}/ 
    mkdir -p ../../logs/${app}/ 
    cd ${app}
    make clean; make
    
    if [[ "${app}" == "backprop" ]]; then
        for i in `seq 8192 1024 65536`; do
			nvprof --metrics all --events all   --print-gpu-trace --csv -u s ${execApps["${app}"]} ${i} 2> temp
            saveTraces
        done
    fi
    
    if [[ "${app}" == "gaussian" ]]; then
        for i in `seq 256 256 8192 `; do
            nvprof --metrics all --events all   --print-gpu-trace --csv -u s ${execApps["${app}"]} -s $i -q 2> temp
            saveTraces
        done
	fi
    
    if [[ "${app}" == "heartwall" ]]; then
        for i in `seq 20 104`; do
			nvprof --metrics all --events all   --print-gpu-trace --csv -u s ${execApps["${app}"]} ../../data/heartwall/test.avi ${i} 2> temp
            saveTraces
        done
    fi
    
    if [[ "${app}" == "hotspot" ]]; then
        for i in 64 512 1024; do
            for j in `seq 32 32 4096 `; do
                nvprof --metrics all --events all   --print-gpu-trace --csv -u s ${execApps["${app}"]} ${i} 2 ${j} ../../data/hotspot/temp_${i} ../../data/hotspot/power_${i} output.out 2> temp
				cat temp | awk -v var=$i  -v var2=$j '{print var"," var2"," $0}' | grep $gpu >> ../../../logs/${app}/${app}-metrics.csv
				
            done
        done
    fi
    
    if [[ "${app}" == "hotspot3D" ]]; then        
        for i in 2 4 8; do
            for j in `seq 100 10 1000 `; do
                nvprof --metrics all --events all   --print-gpu-trace --csv -u s ${execApps["${app}"]} 512 ${i} ${j} ../../data/hotspot3D/power_512x${i} ../../data/hotspot3D/temp_512x${i} output.out 2> temp
				cat temp | awk -v var=$i  -v var2=$j '{print var"," var2"," $0}'  | grep $gpu >> ../../../logs/${app}/${app}-metrics.csv							
            done
        done
    fi      
    
    if [[ "${app}" == "lavaMD" ]]; then
        for i in `seq 5 1 100`; do
            nvprof --metrics all --events all   --print-gpu-trace --csv -u s ${execApps["${app}"]} -boxes1d ${i} 2> temp
            saveTraces
        done
    fi
    
    if [[ "${app}" == "lud" ]]; then
        for i in `seq 256 256 8192`; do
			nvprof --metrics all --events all   --print-gpu-trace --csv -u s ${execApps["${app}"]} -s ${i} -v 2> temp			
            saveTraces
        done
    fi
    
    if [[ "${app}" == "nw" ]]; then        
        for i in `seq 256 256 4096`; do
            for j in `seq 1 10 `; do
                nvprof --metrics all --events all   --print-gpu-trace --csv -u s ${execApps["${app}"]}  ${i} ${j} 2> temp
				cat temp | awk -v var=$i  -v var2=$j '{print var"," var2"," $0}'  | grep $gpu >> ../../../logs/${app}/${app}-metrics.csv								
            done
        done
    fi 
    
    if [[ "${app}" == "pathfinder" ]]; then 
        for i in `seq 100000 100000 1000000`; do
            for j in `seq 10 10 100`; do
                for k in 2 4 8 16 32 64; do
                    nvprof --metrics all --events all   --print-gpu-trace --csv -u s ${execApps["${app}"]} ${i} ${j} ${k} 0 2> temp
					cat temp | awk -v var=$i  -v var2=$j -v var3=$k '{print var"," var2"," var3"," $0}'  | grep $gpu >> ../../../logs/${app}/${app}-metrics.csv									
                done
            done
        done
    fi
    rm -f tempTime temp
  
    cd ..
done
    
cd ../
make clean
cd ../


