require 'csv'
require 'trollop.rb'

# get base dir
BASEDIR = %x[pwd].strip

# set up some command line goodness
opts = Trollop::options do
  version "1.0 JKV"
    banner <<-EOS
    Enron data cleaning program
    Usage: preclassify [opts]
    EOS
  
    opt :relevancecode, "relevancecode", :type => :string
    opt :datadir, "Base Directory where the zip files reside", :type => String
    opt :outdir, "Output dir where files will be written", :type => String
end
Trollop::die :outdir, "must be specified" if opts[:outdir].nil?
Trollop::die :datadir, "must be specified" if opts[:datadir].nil?
# Debug command line
# p opts
#########################################################################################

if File.directory?(opts[:outdir])
  createdir = %x[mkdir -p #{opts[:outdir]}/output/relevant #{opts[:outdir]}/output/notRelevant #{opts[:outdir]}/output/notJudged]
else
  raise "output directory does not exist"
end
OUT_rel = opts[:outdir] + "/" + "output/relevant"
OUT_notrel = opts[:outdir] + "/" + "output/notRelevant"
OUT_notjudge = opts[:outdir] + "/" + "output/notJudged"
#########################################################################################


# create the lookup hash
lookup = Hash.new
CSV.foreach("#{BASEDIR}/data/Relevance.txt",{:col_sep => "\t"}) do |row|
  if opts[:relevancecode].nil?
    lookup[row[2]] = row[3]
  else
    if row[0] == opts[:relevancecode]
      lookup[row[2]] = row[3]
    end
  end
end
# # iterate over it
# lookup.each do |k,v|
#   p k + "," + v
#   break
# end
#########################################################################################

# Read zip files in the data directory and do a lookup
# read files in the data dir
zipfiles = %x[ls #{opts[:datadir]} | grep '.*\.zip'].split("\n")

counter = 0

zipfiles.each do |z|
  files = %x[unzip -l #{opts[:datadir]}/#{z} | awk '{print $NF}' | grep '.*\.txt' | grep -v 'native' | sort].split("\n")
  files.each do |f|
    # eg:: f = text_000/3.540219.K3DZSZHESF0ZHXVPSBL310YDF0BXAO3OA.1.txt
    f_part = f.split("/")[1]
    # f_part gives 3.540219.K3DZSZHESF0ZHXVPSBL310YDF0BXAO3OA.1.txt and now we need just 3.540219.K3DZSZHESF0ZHXVPSBL310YDF0BXAO3OA
    part = f_part.split(".")
    pre_filename = part[0] + "." + part[1] + "." + part[2]
    
    # If there is a match with the lookup
    if lookup.has_key?(pre_filename)
      fullzipfilepath = opts[:datadir]+ "/" + z 
      # p pre_filename + " CLASS LABEL " + lookup[pre_filename] + "    " + fullzipfilepath + " ::: " + f
      counter = counter + 1
      case lookup[pre_filename]
      when "1" # relevant
        %x[unzip -p #{fullzipfilepath} #{f} > #{OUT_rel}/#{f_part}]
        p "(#{counter}) Writing file #{OUT_rel}/#{f_part}"
      when "0" # not relevant
        %x[unzip -p #{fullzipfilepath} #{f} > #{OUT_notrel}/#{f_part}]
        p "(#{counter}) Writing file #{OUT_notrel}/#{f_part}"
      when "-1" # not judged
        %x[unzip -p #{fullzipfilepath} #{f} > #{OUT_notjudge}/#{f_part}]
        p "(#{counter}) Writing file #{OUT_notjudge}/#{f_part}"
      end
    end
  end
  
end



