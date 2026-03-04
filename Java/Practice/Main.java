import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.util.*;

/* ================= MAIN GUI CLASS ================= */
public class VotingSystemGUI extends JFrame {

    private Election election;
    private Map<String, Voter> voters;

    private JTextField voterIdField;
    private JTextField candidateIdField;
    private JTextArea candidateArea;

    public VotingSystemGUI() {
        setTitle("Online Voting System");
        setSize(400, 450);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setLayout(new BorderLayout());

        election = new Election();
        voters = new HashMap<>();

        /* Add Candidates */
        election.addCandidate(new Candidate(1, "Alice"));
        election.addCandidate(new Candidate(2, "Bob"));
        election.addCandidate(new Candidate(3, "Charlie"));

        /* Add Voters */
        voters.put("v1", new Voter("v1"));
        voters.put("v2", new Voter("v2"));
        voters.put("v3", new Voter("v3"));

        /* ================= UI COMPONENTS ================= */
        JPanel inputPanel = new JPanel(new GridLayout(4, 2, 5, 5));

        inputPanel.add(new JLabel("Voter ID:"));
        voterIdField = new JTextField();
        inputPanel.add(voterIdField);

        inputPanel.add(new JLabel("Candidate ID:"));
        candidateIdField = new JTextField();
        inputPanel.add(candidateIdField);

        JButton voteButton = new JButton("Vote");
        JButton resultButton = new JButton("Show Results");
        JButton exitButton = new JButton("Exit");

        inputPanel.add(voteButton);
        inputPanel.add(resultButton);
        inputPanel.add(exitButton);

        add(inputPanel, BorderLayout.NORTH);

        candidateArea = new JTextArea();
        candidateArea.setEditable(false);
        add(new JScrollPane(candidateArea), BorderLayout.CENTER);

        showCandidates();

        /* ================= BUTTON ACTIONS ================= */
        voteButton.addActionListener(e -> castVote());
        resultButton.addActionListener(e -> showResults());
        exitButton.addActionListener(e -> System.exit(0));

        setVisible(true);
    }

    /* ================= METHODS ================= */

    private void showCandidates() {
        candidateArea.setText("Candidates:\n");
        for (Candidate c : election.getCandidates()) {
            candidateArea.append(c.getId() + " - " + c.getName() + "\n");
        }
    }

    private void castVote() {
        String voterId = voterIdField.getText().trim();
        String candidateText = candidateIdField.getText().trim();

        try {
            if (!voters.containsKey(voterId)) {
                throw new InvalidVoterException("Invalid Voter ID");
            }

            Voter voter = voters.get(voterId);
            if (voter.hasVoted()) {
                throw new AlreadyVotedException("Voter has already voted");
            }

            int candidateId = Integer.parseInt(candidateText);

            if (election.vote(candidateId)) {
                voter.setVoted(true);
                JOptionPane.showMessageDialog(this, "Vote Cast Successfully");
            } else {
                JOptionPane.showMessageDialog(this, "Invalid Candidate ID");
            }

        } catch (NumberFormatException e) {
            JOptionPane.showMessageDialog(this, "Candidate ID must be a number");
        } catch (InvalidVoterException | AlreadyVotedException e) {
            JOptionPane.showMessageDialog(this, e.getMessage());
        }
    }

    private void showResults() {
        StringBuilder results = new StringBuilder("Election Results:\n");
        for (Candidate c : election.getCandidates()) {
            results.append(c.getName())
                   .append(" : ")
                   .append(c.getVotes())
                   .append("\n");
        }
        JOptionPane.showMessageDialog(this, results.toString());
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(VotingSystemGUI::new);
    }
}

/* ================= BACKEND CLASSES ================= */

class Voter {
    private String id;
    private boolean voted;

    public Voter(String id) {
        this.id = id;
        this.voted = false;
    }

    public boolean hasVoted() {
        return voted;
    }

    public void setVoted(boolean voted) {
        this.voted = voted;
    }
}

class Candidate {
    private int id;
    private String name;
    private int votes;

    public Candidate(int id, String name) {
        this.id = id;
        this.name = name;
        this.votes = 0;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public int getVotes() {
        return votes;
    }

    public void addVote() {
        votes++;
    }
}

class Election {
    private List<Candidate> candidates = new ArrayList<>();

    public void addCandidate(Candidate c) {
        candidates.add(c);
    }

    public List<Candidate> getCandidates() {
        return candidates;
    }

    public synchronized boolean vote(int id) {
        for (Candidate c : candidates) {
            if (c.getId() == id) {
                c.addVote();
                return true;
            }
        }
        return false;
    }
}

class InvalidVoterException extends Exception {
    public InvalidVoterException(String msg) {
        super(msg);
    }
}

class AlreadyVotedException extends Exception {
    public AlreadyVotedException(String msg) {
        super(msg);
    }
}
