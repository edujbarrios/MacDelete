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

# Mostrar mensaje de resumen
if [ "$count" -eq 0 ]; then
  echo "No se encontraron archivos residuales."
else
  echo "Se han eliminado $count archivos residuales."
fi
