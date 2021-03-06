use strict;
use warnings;


my $in_ori_fileile='IDTP9220_Registers.cpp';
open(my $in_ori_file,$in_ori_fileile)or die "Could not open file'$in_ori_fileile'$!";
my $targetfile='temp.cpp';
open(my $output_file,'>',$targetfile)or die "Could not open file'$targetfile'$!";


while(my $row=<$in_ori_file>)
{
   	if($row=~/^\s+(\w+)\.(\w+)\s+=\s+(\w+)\.(\w+)\s*;/xg)
	{
		my $object = $1;
		my $member = $2;
		my $object2  = $3;
		my $member2 = $4;
		my $class1;
		my $class2;

			my $structfile='Global.cpp';
			open(my $istruct_file,$structfile)or die "Could not open file'$structfile'$!";
	
			while(my $row2=<$istruct_file>)
			{
				if($row2=~/^(\w+)\s+(\w+);/xg){
					if($object eq $object2)
					{
						if($2 eq $object)
						{
							$class1 = $1;
							$class2 = $1;
						}	
					}
					else
					{
						if($2 eq $object)
						{
							$class1 = $1;
						#	print "Im struct read \n";
						}
						else if($2 eq $object2)
						{
							$class2 = $1;	
						}
					}
				}
			}
			#print "debug info $class \n";
			close $istruct_file;
	
			my %member_hash;
			my $lookupfile='IDTP9220_Enums.h';
			open(my $iEnum_file,$lookupfile)or die "Could not open file'$lookupfile'$!";
			$/ = "";
			while(my $row3=<$iEnum_file>)
			{
				my $class_member = qr/\s*(\w+)\s+(\w+);.*\n/;
				my $search_class = qr/$class/;
				#print $output_file $row3;
				chomp($row3);
				if($row3=~/struct\s+$search_class\{([^}]*)\}\;/g){
					#print $output_file $1,"\n";
					my $class_member_all = $1;
					$/ = "\n";
					
					while($class_member_all=~/$class_member/g)
					{					
							$member_hash{"$2"} = $1;#member => member type
							#print  "\/\/$2 => $1\n" ; 						
					}
				}
			}		
			close $iEnum_file;
			my $new_row_format;
			my $member_type = "init";
			if(exists($member_hash{$member})){
				$member_type = $member_hash{$member};
				#print "$member => $member_type\n";
			}
			else{die "Could not find '$member'$!";}
			if($member_type=~/\bint\b/i){
				print $output_file "\t$object\.$member = $value\;\n";
			}
			elsif($member_type=~/\w+Enum/i)
			{
				print $output_file "\t$object\.$member = $member_type\($value\)\;\n";
			}
			elsif($member_type=~/ARRAY/i)
			{
				print $output_file "\t$object\.$member\.init\($value\)\;\n";
			}
			else
			{
				print $output_file $row;
			}
		}
		
			
	}
	else
	{				
	}
	$/ = "\n";
}
close $output_file;
close $in_ori_file;


