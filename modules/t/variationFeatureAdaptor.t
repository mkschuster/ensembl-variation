
use strict;
use warnings;

BEGIN { $| = 1;
	use Test;
	plan tests => 21;
}


use Bio::EnsEMBL::Test::TestUtils;


use Bio::EnsEMBL::Test::MultiTestDB;


our $verbose = 0;

my $multi = Bio::EnsEMBL::Test::MultiTestDB->new();

my $vdb = $multi->get_DBAdaptor('variation');
my $db  = $multi->get_DBAdaptor('core');

$vdb->dnadb($db);

my $vfa = $vdb->get_VariationFeatureAdaptor();
my $va  = $vdb->get_VariationAdaptor();

ok($vfa && $vfa->isa('Bio::EnsEMBL::Variation::DBSQL::VariationFeatureAdaptor'));

my $sa = $db->get_SliceAdaptor();

my $slice = $sa->fetch_by_region('chromosome', '20');



my $vfs = $vfa->fetch_all_by_Slice($slice);

print_feats($vfs);

ok(@$vfs == 63);


my $vf = $vfa->fetch_by_dbID(1857);

ok($vf->start() == 62304671);
ok($vf->end()   == 62304671);
ok($vf->strand() == 1);
ok($vf->allele_string() eq 'G/A');
ok($vf->variation()->name() eq 'rs2039');
ok($vf->display_id() eq 'rs2039');
ok($vf->map_weight() == 1);
ok($vf->slice()->name() eq $slice->name());


# test fetch_all_by_Variation

my $v = $va->fetch_by_dbID(2031);
$vfs = $vfa->fetch_all_by_Variation($v);
ok(@$vfs == 1);
$vf = $vfs->[0];

ok($vf->dbID() == 1857);
ok($vf->slice->name() eq $slice->name());
ok($vf->start == 62304671);
ok($vf->end()   == 62304671);
ok($vf->strand() == 1);
ok($vf->allele_string() eq 'G/A');
ok($vf->variation()->name() eq 'rs2039');
ok($vf->display_id() eq 'rs2039');
ok($vf->map_weight() == 1);
ok($vf->slice()->name() eq $slice->name());



sub print_feats {
  my $feats = shift;
  return if(!$verbose);

  foreach my $f (@$feats) {
    print $f->seq_region_name(), ':', $f->start(), '-', $f->end(), ' ',
          $f->display_id(), ' ', $f->allele_string(), "\n";
  }

}

