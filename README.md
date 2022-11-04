# Cyber Security Widows Configuration Script
# Installing git
```
sudo dnf install git-all
```
# Open Either Windows Command Prompt or PowerShell

# Downloading the Files
```
cd Downloads
git clone https://github.com/JackyF737/cyberconf.git
```
# Run Config Command
```
cd cyberconf
secedit.exe /configure /db %windir%\security\local.sdb /cfg Windows-SECPOL.inf
```
