require 'spec_helper'

describe Venice::Client do
  let(:receipt_data) { "asdfzxcvjklqwer" }
  let(:client) { subject }

  describe "#verify!" do
    context "no shared_secret" do
      before do
        client.shared_secret = nil
        Venice::Receipt.stub :new
      end

      it "should only include the receipt_data" do
        Net::HTTP.any_instance.should_receive(:request) do |post|
          post.body.should eq({'receipt-data' => receipt_data}.to_json)
          post
        end
        client.verify! receipt_data
      end
    end

    context "with a shared secret" do
      let(:secret) { "shhhhhh" }

      before do
        Venice::Receipt.stub :new
      end

      it "should include the secret in the post" do
        Net::HTTP.any_instance.should_receive(:request) do |post|
          post.body.should eq({'receipt-data' => receipt_data, 'password' => secret}.to_json)
          post
        end
        client.verify! receipt_data, shared_secret: secret
      end
    end

    context "with a latest receipt info attribute" do
      before do
        client.stub(:json_response_from_verifying_data).and_return(response)
      end

      let(:latest_receipt_data) { "<encoded string>" }
      let(:response) do
        {
          'status' => 0,
          'receipt' => {},
          'latest_receipt' => latest_receipt_data,
          'latest_receipt_info' =>  [ {
            "expires_date" => "2015-06-10 08:37:06 Etc/GMT",
            "expires_date_ms" => "1433925426000",
            "expires_date_pst" => "2015-06-10 01:37:06 America/Los_Angeles",
            "is_trial_period" => "true",
            "original_purchase_date" => "2015-06-10 08:34:07 Etc/GMT",
            "original_purchase_date_ms" => "1433925247000",
            "original_purchase_date_pst" => "2015-06-10 01:34:07 America/Los_Angeles",
            "original_transaction_id" => "1000000158662856",
            "product_id" => "blloon.unlimited.trial",
            "purchase_date" => "2015-06-10 08:34:06 Etc/GMT",
            "purchase_date_ms" => "1433925246000",
            "purchase_date_pst" => "2015-06-10 01:34:06 America/Los_Angeles",
            "quantity" => "1",
            "transaction_id" => "1000000158662856",
            "web_order_line_item_id" => "1000000029907341"
          } ]
        }
      end

      it "should create a latest receipt" do
        receipt = client.verify! 'asdf'
        receipt.latest_receipt.should == latest_receipt_data
        receipt.latest_receipt_info.should be_a(Array)
      end

      it "should create a latest receipt" do
        receipt = client.verify! 'asdf'
        last_tx = receipt.latest_receipt_info.last
        last_tx.transaction_id.should == "1000000158662856"
      end
    end

  end
end
