# README

Script(s) to (auto)generate CTA Disk Wipe Certificates

## Requirements
### For the Python wrapper
- dialog
- pythondialog

### For the core Bash script
- pandoc
- texlive-latex-recommended
- texlive-latex-extra

### For the systemd service
- inotify-tools

### For the SAMBA share
- samba

## Files

`BashGenCerts.sh` - A bash script to generate certificate PDF from nwipe logfile. Takes two arguments: inputFile, outputFolder.

`Certs.service` - Systemd service file to watch a folder for new logfiles and then automatically run `BashGenCerts.sh` on them.

`CTA.tex` - A .tex file specify the certificates formatting.

`CTALogo.png` - A resource for the final PDFs.

`CTASecureWipeCerts.py` - A python wrapper of `BashGenCerts.sh`, that adds a UI and other functionality.

`example.pdf` - An example output PDF of a certificate.

`example_log_1234_20231231-121212.txt` - An example input logfile from nwipe.

`README` - This file.

`smb.conf` - An example Samba config file to enable a network share of the generated certificates.

## Usage
### BashGenCerts.sh
`BashGenCerts.sh example_log_1234_20231231-121212.txt ./certs`

### CTASecureWipeCerts.py
`CTASecureWipeCerts.py`

## Installation
### Scripts
Copy files to /usr/local/bin/
```bash
sudo cp ./BashGenCerts.sh /usr/local/bin/BashGenCerts.sh
sudo cp ./CTASecureWipeCerts.py /usr/local/bin/CTASecureWipeCerts
```
Copy resources to /usr/share/
```bash
sudo cp ./CTA.tex /usr/share/
sudo cp ./CTALogo.png /usr/share/
```

### Service
Copy .service file to system folder, reload services and then start and enable the service.
```bash
sudo cp ./Certs.service /etc/systemd/system/Certs.service
sudo systemctl daemon-reload
sudo systemctl enable --now Certs.service
```

## Samba share
To enable everyone in the office to easily access the generated certificates over the network a Samba server and share was set up. Here are the details:

```bash
# Install Samba
sudo apt install samba

# Edit /etc/samba/smb.conf
sudo nano /etc/samba/smb.conf
# or use example
sudo cp ./smb.conf /etc/samba/

# Sort out guest user
sudo su -
useradd guest -s /bin/nologin
# Add user to netboot-log group so they can read files
addgroup guest netboot-log

# start / enable smbd.service
sudo systemctl enable --now smbd
```

### Viewing in Windows

To view share in Windows:
- Open File Explorer
- Type in `\\Theta\cert_share`

To pin location:
- Click Home
- Click Pin to Quick Access
