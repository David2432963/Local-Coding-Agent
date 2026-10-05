@echo off
setlocal
for %%I in ("%~dp0..") do set "REPO_ROOT=%%~fI"
if not defined LCA_CONFIG_PATH if exist "%REPO_ROOT%\setup.json" set "LCA_CONFIG_PATH=%REPO_ROOT%\setup.json"
node "%~dp0local-coding-agent.mjs" %*
