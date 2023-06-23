# How to write an extension

If you want to include a new extension in this module, you simply have to create a new folder in the `extensions` directory, containing the script configuration `json` and `sh` file required to define the extension.
The folder must be named after the extension name you want to use, and that you will later use to reference it

The json file is used by the VM to locate the executable file, while the executable contains the actual "source" of the extension.

[Here](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux)'s the official documentation on how to write an extension


**N.B.:** json file MUST be named `script-config.json` since by convention that's the name that is looked for by this module

Then you simply need to reference the new extension name when using this module

**N.B.:** be sure to double-check the path defined in `script-config.json`, since you will not get any warning
