Naming conventions
==================

These naming conventions are provided to make loading files easier.
Usually, the convention stems either from the software used or from what
emerged as the most common choice during data collection. This should limit
the number of manual corrections needed.

### Subject codes
Six-letter subject codes are used, either capitalised (Abcdef) or in all-caps
(ABCDEF), depending on file type. If the code got misspelled during entry
(for example on scanner console or in Presentation) it should be manually
edited to maintain consistency (so that the code assigned is being used
throughout). Data files collected from observer only (MR, pulse, EDA) must not
contain numbers.

### DICOM files

Dicom files should be stored in hierarchical folders, as created by Horos.
The subject code should be capitalised and prefixed by *Ec_*.

`Ec_Abcdef/*/*/IM-0000-0000.dcm`


### Pulse files

In pulse files, both prefix and subject code should be written in all-caps,
while task name (if present) should be suffixed in lowercase:

`EC_ABCDEF_ofl.puls` or `EC_ABCDEF.puls`

### NIfTi files

Subject codes in NIfTi files should be capitalised, following the Horos
convention. The Ec prefix must not be present.

### Presentation logfiles
Log files created by presentation should use six-letter codes in all-caps.

### Markdown files

Names of markdown files should use underscores, never spaces.
