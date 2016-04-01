cdrlist=($(pwd))
function cdr {
  if [ $# -eq 0 ]; then
    # listing
    n=0
    cur=$(pwd)
    echo
    for d in ${cdrlist[@]}; do
      if [[ $d = $cur ]]; then
        dn="\e[31m$d\e[0m \e[5;31m*\e[0m"
      elif [[ $d =~ ^$cur ]]; then
        dn="\e[31m${d:0:${#cur}}\e[34m${d:${#cur}}\e[0m"
      else
        dn="\e[0m$d\e[0m"
      fi
      echo -e "  \e[1;36m$n\e[0m  $dn"
      let n++
    done
    return
  fi

  # implicit -d option
  fargs=('-d' $@)

  # interpret options
  optlen=0
  arglen=0
  for a in ${fargs[@]}; do
    if [[ $a =~ ^- ]]; then
      oname=${a:1}
      eval opt_${optlen}_name="\${oname}"
      eval opt_${optlen}_args=\(\)
      let optlen++
      arglen=0
    else
      let optlast=optlen-1
      eval opt_${optlast}_args[\$arglen]=\$a
      let arglen++
    fi
  done

  for oi in $(seq 0 $(( optlen - 1 ))); do
    oname="$(eval echo \$opt_${oi}_name)"
    oargs="$(eval echo \${opt_${oi}_args[@]})"
    if [[ $oname =~ ^[0-9]+$ ]]; then
      if [ $oname -lt ${#cdrlist[@]} ]; then
        cd ${cdrlist[$oname]}
      else
        echo "index out of range: $oi"
      fi
    else
      case $oname in
        'c' ) cdrlist=()
              ;;
        'd' ) for d in ${oargs[@]}; do
                cd $d
                if [ $? -eq 0 ]; then
                  cdrlist[${#cdrlist[@]}]=$(pwd)
                fi
              done
              cdrlist=($(for i in ${cdrlist[@]}; do echo $i; done | sort | uniq))
              ;;
        'p' ) for pi in ${oargs[@]}; do
                echo "purged: ${cdrlist[$pi]}"
                cdrlist[$pi]=''
              done
              cdrlist=($(for i in ${cdrlist[@]}; do if [[ $i != '' ]]; then echo $i; fi; done))
              ;;
         *  ) echo "unrecognized option: $oname"
      esac
    fi
  done
}
