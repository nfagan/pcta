function meta_file = meta(source_file)

meta_file = struct();
meta_file.identifier = source_file.identifier;
meta_file.date = pcta.util.mat_filename_to_datestr( source_file.identifier );
meta_file.day = datestr( meta_file.date, 'mmddyy' );
meta_file.subject = source_file.config.META.subject;

end