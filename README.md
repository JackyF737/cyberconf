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



# Cyber Security Linux Configuration Script
# Enter Sudo
```
sudo su
```
# Installing git
```
sudo apt-get install git
```

# Downloading the Files
```
git clone https://github.com/JackyF737/cyberconf.git
```
# Run Config Command
```
cd cyberconf
bash auto-security-linux.sh
```
