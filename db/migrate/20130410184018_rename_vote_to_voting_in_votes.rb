class RenameVoteToVotingInVotes < ActiveRecord::Migration
  def change
    rename_column :votes, :vote, :voting
  end
end
