# Directorios a escanear
DIRECTORIES_TO_SCAN=(
  "$HOME/Library/Caches"
  "$HOME/Library/Logs"
  "$HOME/Library/Safari"
  "$HOME/Library/Containers"
  "/Library/Caches"
  "/Library/Logs"
  # Más directorios con posibles archivos residuales
  "/System/Library/Caches"
  "/Users/Shared/Cache"
  "/var/log"
  #Directorios que más uso tienen en mi caso particular
  "$HOME/Music/Audio Music Applications/Logic/Audio Components Cache"
  "$HOME/Library/Application Support/Google/Chrome/Default/Cache")

# Tiempo en días para considerar un archivo residual
TIME_THRESHOLD=30

# Contador de archivos eliminados
count=0

# Eliminar archivos residuales en cada directorio
for dir in "${DIRECTORIES_TO_SCAN[@]}"; do
  count=$((count + $(find "$dir" -type f -mtime +$TIME_THRESHOLD -print0 | xargs -0 rm -f | wc -l)))
done

# Tiempo en días para considerar un archivo residual
if [ $# -eq 0 ]
  then
    TIME_THRESHOLD=30
  else
    TIME_THRESHOLD=$1
fi

# Mostrar archivos residuales
show_files=false
while getopts "ls" opt; do
  case $opt in
    l)
      show_files=true
      ;;
    s)
      show_files=false
      ;;
    \?)
      echo "Opción inválida: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

for dir in "${DIRECTORIES_TO_SCAN[@]}"; do
  if [ "$show_files" = true ] ; then
    find "$dir" -type f -mtime +$TIME_THRESHOLD -print0
  else
    count=$((count + $(find "$dir" -type f -mtime +$TIME_THRESHOLD -print0 | xargs -0 rm -f | wc -l)))
  fi
done

if [ "$show_files" = true ] ; then
  echo "Lista de archivos residuales:"
fi


# Mostrar mensaje de resumen
if [ "$count" -eq 0 ]; then
  echo "No se encontraron archivos residuales."
else
  echo "Se han eliminado $count archivos residuales."
fi

# Hacer copia de seguridad de los archivos residuales
backup_files=false
while getopts "lb" opt; do
  case $opt in
    l)
      show_files=true
      ;;
    b)
      backup_files=true
      ;;
    \?)
      echo "Opción inválida: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

backup_dir="$HOME/Library/Residual Files Backup $(date +%Y-%m-%d_%H-%M-%S)"
mkdir "$backup_dir"

for dir in "${DIRECTORIES_TO_SCAN[@]}"; do
  if [ "$show_files" = true ] ; then
    find "$dir" -type f -mtime +$TIME_THRESHOLD -print0
  elif [ "$backup_files" = true ] ; then
    find "$dir" -type f -mtime +$TIME_THRESHOLD -exec mv {} "$backup_dir" \;
  else
    count=$((count + $(find "$dir" -type f -mtime +$TIME_THRESHOLD -print0 | xargs -0 rm -f | wc -l)))
  fi
done

if [ "$backup_files" = true ] ; then
  echo "Se han realizado copias de seguridad de los archivos residuales en $backup_dir"
fi

# Excluir ciertos tipos de archivos de la eliminación
EXCLUDE_FILE_TYPES=(".jpg" ".jpeg" ".png" ".wav" ".mp4")

for dir in "${DIRECTORIES_TO_SCAN[@]}"; do
  if [ "$show_files" = true ] ; then
    find "$dir" -type f -mtime +$TIME_THRESHOLD -not -name "${EXCLUDE_FILE_TYPES[@]}" -print0
  elif [ "$backup_files" = true ] ; then
    find "$dir" -type f -mtime +$TIME_THRESHOLD -not -name "${EXCLUDE_FILE_TYPES[@]}" -exec mv {} "$backup_dir" \;
  else
    count=$((count + $(find "$dir" -type f -mtime +$TIME_THRESHOLD -not -name "${EXCLUDE_FILE_TYPES[@]}" -print0 | xargs -0 rm -f | wc -l)))
  fi
done
