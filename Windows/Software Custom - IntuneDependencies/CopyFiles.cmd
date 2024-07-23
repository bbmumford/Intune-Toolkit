if not exist "C:\IntuneDependencies" MD "C:\IntuneDependencies\" 

### Files to copy
copy /Y ".\Desktop_Wallpaper.png" C:\IntuneDependencies\
@REM copy /Y ".\RGM_TaskBar_Layout.xml" C:\IntuneDependencies\

echo [Files Copied] > C:\IntuneDependencies\DependeciesCopied.txt