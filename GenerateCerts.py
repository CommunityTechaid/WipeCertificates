#!/usr/bin/python3
import locale
import sys
import time
import os
import os.path
from dialog import Dialog

log_file_prefix = "nwipe_log_"
input_folder = "./"
output_folder = os.environ['HOME']
output_prefix = "CTAWipeReport-"

locale.setlocale(locale.LC_ALL, '')

# settings = '''dialog_color = (BLACK,WHITE,OFF)
# title_color = (BLUE,WHITE,ON)
# border_color = (WHITE,WHITE,ON)
# button_active_color = (WHITE,BLUE,ON)'''


# Function to check folder and return list of files
def list_log_files(log_folder_path):
    list_of_files = [file for file in os.listdir(log_folder_path) if os.path.isfile(os.path.join(log_folder_path, file))]
    log_files = [file for file in list_of_files if file.startswith(log_file_prefix)]
    return log_files


# Function to get id from filename
def device_id_from_filename(filename):
    if filename.startswith(log_file_prefix):
        split_filename = filename.split("_")
        device_id = split_filename[2]
        if device_id.isnumeric():
            return device_id


# d = Dialog(dialog="dialog", DIALOGRC="./CTA.rc")
d = Dialog(dialog="dialog")
# Dialog.set_background_title() requires pythondialog 2.13 or later
d.set_background_title("CTA Disk Wipe Certification")

d.infobox("Welcome to the CTA Disk Wipe Certificate generation program.")
time.sleep(1)

while True:
    code, tag = d.menu("Here are your options:",
                       choices=[("(1)", "Generate certificate from device ID"),
                                ("(2)", "Batch generate certificates"),
                                ("(3)", "Change output file location"),
                                ("(4)", "Change input logfile location"),
                                ("Q", "Quit")],
                       title="Menu")

    if code == d.OK:
        # 'tag' is now one of the options
        pass
        if tag == "Q":
            sys.exit(0)
        # From ID
        elif tag == "(1)":
            code, device_id = d.inputbox("Enter device ID:")
            if code == d.OK:
                if device_id.isnumeric():
                    # d.infobox("You entered: "+str(device_id))
                    time.sleep(1)
                    list_of_files = list_log_files(input_folder)
                    device_id_string = "_"+device_id+"_"
                    matches = [m for m in list_of_files if device_id_string in m]
                    if len(matches) > 1:
                        d.infobox("We seem to have multiple files for "+str(device_id))
                        time.sleep(1)
                    elif len(matches) == 0:
                        d.infobox("We don't seem to have a file for "+str(device_id))
                        time.sleep(1)
                    else:
                        d.gauge_start("Generating certificate...")
                        time.sleep(1)
                        for m in matches:
                            # Generate certs
                            os.system("./GenCerts.sh "+os.path.join(input_folder, m)+" "+output_folder)
                        d.gauge_update(100, "Done")
                        time.sleep(1)
                        d.gauge_stop
                else:
                    d.msgbox("You entered a non-numeric ID.")

        # Batch generate
        elif tag == "(2)":
            # d.msgbox("You selected batch generate certs")
            device_choices = []
            list_of_files = list_log_files(input_folder)
            for file in list_of_files:
                device_id = device_id_from_filename(file)
                device_choices.append((file, device_id, "off"))
            code, devices = d.checklist("Select devices to generate certs for",
                                        choices=device_choices,
                                        title="Devices")
            if code == d.OK:
                # d.msgbox("You selected "+str(len(devices))+"devices:\n"+str(devices))
                counter = 0
                total = len(devices)
                increment = int(100 / total)
                d.gauge_start("Generating "+str(total)+" certificates...")
                time.sleep(1)
                for dev in devices:
                    # Generate certs
                    os.system("./GenCerts.sh "+os.path.join(input_folder, dev)+" "+output_folder)
                    d.gauge_update(increment)
                d.gauge_update(100, "Done")
                time.sleep(1)
                d.gauge_stop

        # Edit output path
        elif tag == "(3)":
            code, path = d.dselect(output_folder)
            if code == d.OK:
                output_folder = path
        # Edit input path
        elif tag == "(4)":
            code, path = d.dselect(input_folder)
            if code == d.OK:
                input_folder = path
    elif code == d.ESC:
        sys.exit(0)
    elif code == d.CANCEL:
        sys.exit(0)


# Function to generate PDF from log file
# generate_cert(path_to_log_file) {

# }

# Fucntion to find log file from ID
