type Lsys::Logrotate = Struct[
  {
    # Old versions of log files are compressed with gzip(1) by default. See also nocompress.
    Optional[compress] => Boolean,
    # Specifies which command to use to compress log files. The default is gzip(1). See also compress.
    Optional[compresscmd] => String,
    # Make  a copy of the log file, but don't change the original at all. This option can be used, for instance, to make a snapshot of
    # the current log file, or when some other utility needs to truncate or parse the file. When this option is used, the create option
    # will have no effect, as the old log file stays in place.
    Optional[copy] => Boolean,
    # Truncate the original log file to zero size in place after creating a copy, instead of moving the old log file and optionally
    # creating a new one. It can be used when some program cannot be told to close its logfile and thus might continue writing
    # (appending) to the previous log file forever. Note that there is a very small time slice between copying the file and truncating
    # it, so some logging data might be lost. When this option is used, the create option will have no effect, as the old log file stays
    # in place.
    Optional[copytruncate] => Boolean,
    # Archive old versions of log files adding a date extension like YYYYMMDD instead of simply adding a number. The extension may be
    # configured using the dateformat and dateyesterday options.
    Optional[dateext] => Boolean,
    # Use yesterday's instead of today's date to create the dateext extension, so that the rotated log file has a date in its name that
    # is the same as the timestamps within it.
    Optional[dateyesterday] => Boolean,
    # Use hour ago instead of current date to create the dateext extension, so that the rotated log file has a hour in its name that is
    # the same as the timestamps within it. Useful with rotate hourly.
    Optional[datehourago] => Boolean,
    # Postpone compression of the previous log file to the next rotation cycle. This only has effect when used in combination with
    # compress. It can be used when some program cannot be told to close its logfile and thus might continue writing to the previous log
    # file for some time.
    Optional[delaycompress] => Boolean,
    Optional[ifempty] => Boolean,
    # When using the mail command, mail the just-rotated file, instead of the about-to-expire file.
    Optional[mailfirst] => Boolean,
    # When using the mail command, mail the about-to-expire file, instead of the just-rotated file (this is the default).
    Optional[maillast] => Boolean,
    # If the log file is missing, go on to the next one without issuing an error message. See also nomissingok.
    Optional[missingok] => Boolean,
    # Old versions of log files are not compressed. See also compress.
    Optional[nocompress] => Boolean,
    # Do not copy the original log file and leave it in place. (this overrides the copy option).
    Optional[nocopy] => Boolean,
    # Do not truncate the original log file in place after creating a copy (this overrides the copytruncate option).
    Optional[nocopytruncate] => Boolean,
    # New log files are not created (this overrides the create option).
    Optional[nocreate] => Boolean,
    # olddir directory is not created by logrotate when it does not exist.
    Optional[nocreateolddir] => Boolean,
    # Do not postpone compression of the previous log file to the next rotation cycle (this overrides the delaycompress option).
    Optional[nodelaycompress] => Boolean,
    # Do not archive  old versions of log files with date extension (this overrides the dateext option).
    Optional[nodateext] => Boolean,
    # Do not mail old log files to any address.
    Optional[nomail] => Boolean,
    # If a log file does not exist, issue an error. This is the default.
    Optional[nomissingok] => Boolean,
    # Logs are rotated in the directory they normally reside in (this overrides the olddir option).
    Optional[noolddir] => Boolean,
    # Run prerotate and postrotate scripts for every log file which is rotated (this is the default, and overrides the sharedscripts
    # option). The absolute path to the log file is passed as first argument to the script. If the scripts exit with error, the
    # remaining actions will not be executed for the affected log only.
    Optional[nosharedscripts] => Boolean,
    # Do not use shred when deleting old log files. See also shred.
    Optional[noshred] => Boolean,
    # Do not rotate the log if it is empty (this overrides the ifempty option).
    Optional[notifempty] => Boolean,
    # Log file is renamed to temporary filename in the same directory by adding ".tmp" extension to it. After that, postrotate script is
    # run and log file is copied from temporary filename to final filename. This allows storing rotated log files on the different
    # devices using olddir directive. In the end, temporary filename is removed.
    Optional[renamecopy] => Boolean,
    # Normally, prerotate and postrotate scripts are run for each log which is rotated and the absolute path to the log file is passed
    # as first argument to the script. That means a single script may be run multiple times for log file entries which match multiple
    # files (such as the /var/log/news/* example). If sharedscripts is specified, the scripts are only run once, no matter how many logs
    # match the wildcarded pattern, and whole pattern is passed to them. However, if none of the logs in the pattern require rotating,
    # the scripts will not be run at all. If the scripts exit with error, the remaining actions will not be executed for any logs. This
    # option overrides the nosharedscripts option and implies create option.
    Optional[sharedscripts] => Boolean,
    # Delete log files using shred -u instead of unlink(). This should ensure that logs are not readable after their scheduled deletion;
    # this is off by default. See also noshred.
    Optional[shred] => Boolean,
    # Specifies which command to use to uncompress log files. The default is gunzip(1).
    Optional[uncompresscmd] => String,
    # Specifies which extension to use on compressed logfiles, if compression is enabled. The default follows that of the configured
    # compression command.
    Optional[compressext] => String,
    # Command line options may be passed to the compression program, if one is in use. The default, for gzip(1), is "-6" (biased towards
    # high compression at the expense of speed). If you use a different compression command, you may need to change the compressoptions
    # to match.
    Optional[compressoptions] => String,
    # Log files with ext extension can keep it after the rotation. If compression is used, the compression extension (normally .gz)
    # appears after ext. For example you have a logfile named mylog.foo and want to rotate it to mylog.1.foo.gz instead of mylog.foo.1.gz.
    Optional[extension] => String,
    # Log files are given the final extension ext after rotation. If the original file already ends with ext, the extension is not
    # duplicated, but merely moved to the end, that is both filename and filenameext would get rotated to filename.1ext. If compression is
    # used, the compression extension (normally .gz) appears after ext.
    Optional[addextension] => String,
    # When a log is rotated out of existence, it is mailed to address. If no mail should be generated by a particular log, the nomail
    # directive may be used.
    Optional[mail] => String,
    # The lines between postrotate and endscript (both of which must appear on lines by themselves) are executed (using /bin/sh) after
    # the log file is rotated. These directives may only appear inside a log file definition. Normally, the absolute path to the log
    # file is passed as first argument to the script. If sharedscripts is specified, whole pattern is passed to the script. See also
    # prerotate. See sharedscripts and nosharedscripts for error handling.
    Optional[postrotate] => Variant[String, Boolean],
    # The lines between prerotate and endscript (both of which must appear on lines by themselves) are executed (using /bin/sh) before
    # the log file is rotated and only if the log will actually be rotated. These directives  may only appear inside a log file
    # definition. Normally, the absolute path to the log file is passed as first argument to the script. If  sharedscripts is specified,
    # whole pattern is passed to the script. See also postrotate. See sharedscripts and nosharedscripts for error handling.
    Optional[prerotate] => String,
    # The lines between firstaction and endscript (both of which must appear on lines by themselves) are executed (using /bin/sh) once
    # before all log files that match the wildcarded pattern are rotated, before prerotate script is run and only if at least one log
    # will actually be rotated. These directives may only appear inside a log file definition. Whole pattern is passed to the script as
    # first argument. If the script exits with error, no further processing is done. See also lastaction.
    Optional[firstaction] => String,
    # The lines between lastaction and endscript (both of which must appear on lines by themselves) are executed (using /bin/sh) once
    # after all log files that match the wildcarded pattern are rotated, after postrotate script is run and only if at least one log is
    # rotated. These directives may only appear inside a log file definition. Whole pattern is passed to the script as first argument.
    # If the script exits with error, just an error message is shown (as this is the last action). See also firstaction.
    Optional[lastaction] => String,
    # The lines between preremove and endscript (both of which must appear on lines by themselves) are executed (using /bin/sh) once
    # just before removal of a log file. The logrotate will pass the name of file which is soon to be removed. See also firstaction.
    Optional[preremove] => String,
    # The  current  taboo  extension  list is changed (see the include directive for information on the taboo extensions). If a + precedes
    # the list of extensions, the current taboo extension list is augmented, otherwise it is replaced. At startup, the taboo extension
    # list ,v, .cfsaved, .disabled, .dpkg-bak, .dpkg-del, .dpkg-dist, .dpkg-new, .dpkg-old, .rhn-cfg-tmp-*, .rpm‐new, .rpmorig, .rpmsave,
    # .swp, .ucf-dist, .ucf-new, .ucf-old, ~
    Optional[tabooext] => String,
    # The current taboo glob pattern list is changed (see the include directive for information on the taboo extensions and patterns). If
    # a + precedes the list of patterns, the current taboo pattern list is augmented, otherwise it is replaced. At startup, the taboo
    # pattern list is empty.
    Optional[taboopat] => String,
    # Do not rotate logs which are less than <count> days old.
    Optional[minage] => Integer,
    # Remove rotated logs older than <count> days. The age is only checked if the logfile is to be rotated.
    # The files are mailed to the configured address if maillast and  mail  are  configured.
    Optional[maxage] => Integer,
    # Log files are rotated when they grow bigger than size bytes even before the additionally specified time interval (daily, weekly,
    # monthly, or yearly). The related size option is similar except that it is mutually exclusive with the time interval options, and it
    # causes log files to be rotated without regard for the last rotation time. When maxsize is used, both the size and timestamp of a log
    # file are considered.
    Optional[maxsize] => Logrotate::Size,
    # Log  files  are  rotated when they grow bigger than size bytes, but not before the additionally specified time interval (daily,
    # weekly, monthly, or yearly).  The related size option is similar except that it is mutually exclusive with the time interval options,
    # and it causes log files to be rotated without regard for the last rotation time. When minsize is used, both the size and timestamp
    # of a log file are considered.
    Optional[minsize] => Logrotate::Size,
    # Log  files are rotated only if they grow bigger than size bytes. If size is followed by k, the size is assumed to be in kilobytes.
    # If the M is used, the size is in megabytes, and if G is used, the size is in gigabytes. So size 100, size 100k, size 100M and size
    # 100G are all valid.
    Optional[size] => Logrotate::Size,
    # Log  files  are rotated count times before being removed or mailed to the address specified in a mail directive. If count is 0,
    # old versions are removed rather than rotated. Default is 0.
    Optional[rotate] => Integer,
    # Asks GNU shred(1) to overwrite log files count times before deletion.  Without this option, shred's default will be used.
    Optional[shredcycles] => Integer,
    # This is the number to use as the base for rotation. For example, if you specify 0, the logs will be created with a .0 extension as
    # they are rotated from the original log files. If you specify 9, log files will be created with a .9, skipping 0-8. Files will still
    # be rotated the number of times specified with the rotate directive.
    Optional[start] => Integer,
    # Immediately after rotation (before the postrotate script is run) the log file is created (with the same name as the log file just
    # rotated). mode specifies the mode for the log file in octal (the same as chmod(2)), owner specifies the user name who will own the
    # log file, and group specifies the group the log file will belong to. Any of the log file attributes may be omitted, in which case
    # those attributes for the new file will use the same values as the original log file for the omitted attributes. This option
    # can be disabled using the nocreate option.
    Optional[create] => Pattern[/^([0-7]{4} )?[a-zA-Z][a-zA-Z0-9_.-]{1,31} [a-zA-Z][a-zA-Z0-9_.-]{1,31}$/],
    # If the directory specified by olddir directive does not exist, it is created. mode specifies the mode for the olddir directory in
    # octal (the same as chmod(2)), owner specifies the user name who will own the olddir directory, and group specifies the group the
    # olddir directory will belong to. This option can be disabled using the nocreateolddir option.
    Optional[createolddir] => Pattern[/^[0-7]{4} [a-zA-Z][a-zA-Z0-9_.-]{1,31} [a-zA-Z][a-zA-Z0-9_.-]{1,31}$/],
    # Specify the extension for dateext using the notation similar to strftime(3) function. Only %Y %m %d %H %M %S %V and %s specifiers
    # are allowed. The default value is -%Y%m%d except hourly, which uses -%Y%m%d%H as default value. Note that also the character
    # separating log name from the extension is part of the dateformat string. The system clock must be set past Sep 9th 2001 for %s to
    # work correctly. Note that the datestamps generated by this format must be lexically sortable (that is first the year, then the
    # month then the day. For example 2001/12/01 is ok, but 01/12/2001 is not, since 01/11/2002 would sort lower while it is later).
    # This is because when using the rotate option, logrotate sorts all rotated filenames to find out which logfiles are older and
    # should be removed.
    Optional[su] => Pattern[/^[a-zA-Z][a-zA-Z0-9_.-]{1,31} [a-zA-Z][a-zA-Z0-9_.-]{1,31}$/],
    # Specify the extension for dateext using the notation similar to strftime(3) function. Only %Y %m %d %H %M %S %V and %s specifiers
    # are allowed. The default value is -%Y%m%d except hourly, which uses -%Y%m%d%H as default value. Note that also the character
    # separating log name from the extension is part of the dateformat string. The system clock must be set past Sep 9th 2001 for %s to
    # work correctly. Note that the datestamps generated by this format must be lexically sortable (that is first the year, then the
    # month then the day. For example 2001/12/01 is ok, but 01/12/2001 is not, since 01/11/2002 would sort lower while it is later).
    # This is because when using the rotate option, logrotate sorts all rotated filenames to find out which logfiles are older and
    # should be removed.
    Optional[dateformat] => Pattern[/^[_a-zA-Z0-9.-]?(%[YmdHMSVs]|[_a-zA-Z0-9.-])+$/],
    Optional[include] => Stdlib::Unixpath,
    # Logs are moved into directory for rotation. The directory must be on the same physical device as the log file being rotated,
    # unless copy, copytruncate or renamecopy option is used. The directory  is assumed to be relative to the directory holding the log
    # file unless an absolute path name is specified. When this option is used all old versions of the log end up in directory. This
    # option may be overridden by the noolddir option.
    Optional[olddir] => Stdlib::Unixpath,
    Optional[hourly] => Boolean,
    # Log files are rotated every day.
    Optional[daily] => Boolean,
    # Log files are rotated once each weekday, or if the date is advanced by at least 7 days since the last rotation (while ignoring the
    # exact time). The weekday interpretation is following: 0 means Sunday, 1 means Monday, ..., 6 means Saturday; the special value 7
    # means each 7 days, irrespectively of weekday.  Defaults to 0 if the weekday argument is omitted.
    Optional[weekly] => Variant[Integer[0, 7], Boolean],
    # Log files are rotated the first time logrotate is run in a month (this is normally on the first day of the month).
    Optional[monthly] => Boolean,
    # Log files are rotated if the current year is not the same as the last rotation.
    Optional[yearly] => Boolean,
  }
]
