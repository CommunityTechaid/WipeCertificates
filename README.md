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

## Files
`CTA.tex` - A .tex file specify the certificates formatting.

`CTALogo.png` - A resource for the final PDFs.

`Certs.service` - Systemd service file to watch a folder for new logfiles and then automatically run `BashGenCerts.sh` on them.

`BashGenCerts.sh` - A bash script to generate certificate PDF from nwipe logfile. Takes two arguments: inputFile, outputFolder.

`CTASecureWipeCerts.py` - A python wrapper of `BashGenCerts.sh`, that adds a UI and other functionality.

`README` - This file.

`example.pdf` - An example output PDF of a certificate.

`example_log_1234_20231231-121212.txt` - An example input logfile from nwipe.

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

### Service
Copy .service file to system folder, reload services and then start and enable the service.
```bash
sudo cp ./Certs.service /etc/systemd/system/Certs.service
sudo systemctl daemon-reload
sudo systemctl start Certs.service
sudo systemctl enable Certs.service
```