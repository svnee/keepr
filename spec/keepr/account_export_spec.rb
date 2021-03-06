require 'spec_helper'

describe Keepr::AccountExport do
  let!(:account_1000)  { FactoryGirl.create :account, :kind => :asset,     :number => 1000,  :name => 'Kasse'                     }
  let!(:account_1776)  { FactoryGirl.create :account, :kind => :liability, :number => 1776,  :name => 'Umsatzsteuer 19 %'         }
  let!(:account_4920)  { FactoryGirl.create :account, :kind => :expense,   :number => 4920,  :name => 'Telefon'                   }
  let!(:account_8400)  { FactoryGirl.create :account, :kind => :revenue,   :number => 8400,  :name => 'Erlöse 19 %'               }
  let!(:account_9000)  { FactoryGirl.create :account, :kind => :neutral,   :number => 9000,  :name => 'Saldenvorträge Sachkonten' }
  let!(:account_10000) { FactoryGirl.create :account, :kind => :creditor,  :number => 10000, :name => 'Diverse Kreditoren'        }
  let!(:account_70000) { FactoryGirl.create :account, :kind => :debtor,    :number => 70000, :name => 'Diverse Debitoren'         }

  let(:scope) { Keepr::Account.all }

  let(:export) {
    Keepr::AccountExport.new(scope,
      'Berater'     => 1234567,
      'Mandant'     => 78901,
      'WJ-Beginn'   => Date.new(2016,1,1),
      'Bezeichnung' => 'Keepr-Konten'
    ) do |account|
      { 'Sprach-ID' => 'de-DE' }
    end
  }

  describe :to_s do
    subject { export.to_s }

    def account_lines
      subject.lines[2..-1].map { |line| line.encode(Encoding::UTF_8) }
    end

    it "should return CSV lines" do
      subject.lines.each { |line| expect(line).to include(';') }
    end

    it "should include header data" do
      expect(subject.lines[0]).to include('1234567;')
      expect(subject.lines[0]).to include('78901;')
      expect(subject.lines[0]).to include('"Keepr-Konten";')
    end

    it "should include all accounts except debtor/creditor" do
      expect(account_lines.count).to eq(5)

      expect(account_lines[0]).to include('1000;')
      expect(account_lines[0]).to include('"Kasse";')

      expect(account_lines[1]).to include('1776;')
      expect(account_lines[1]).to include('"Umsatzsteuer 19 %";')

      expect(account_lines[2]).to include('4920;')
      expect(account_lines[2]).to include('"Telefon";')

      expect(account_lines[3]).to include('8400;')
      expect(account_lines[3]).to include('"Erlöse 19 %";')

      expect(account_lines[4]).to include('9000;')
      expect(account_lines[4]).to include('"Saldenvorträge Sachkonten";')
    end

    it "should include data from block" do
      expect(account_lines[0]).to include(';"de-DE"')
      expect(account_lines[1]).to include(';"de-DE"')
    end
  end

  describe :to_file do
    it "should create CSV file" do
      Dir.mktmpdir do |dir|
        filename = "#{dir}/EXTF_Kontenbeschriftungen.csv"
        export.to_file(filename)

        expect(File).to exist(filename)
      end
    end
  end
end
