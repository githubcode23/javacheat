 package day4; import javax.swing.*; import java.awt.*; import java.util.ArrayList; import java.util.List; import java.util.Random;
public class BouncingBalls extends JPanel {     private static final int WIDTH = 800;     private static final int HEIGHT = 600;     private static final int BALL_SIZE = 30;     private static final int MAX_SPEED = 5;
    private static final Color[] COLORS = {Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW, Color.ORANGE};
    private static class Ball {         private int x;         private int y;         private int dx;         private int dy;         private Color color;
        public Ball(int x, int y, int dx, int dy, Color color) {
            this.x = x;
            this.y = y;             this.dx = dx;             this.dy = dy;             this.color = color;
        }
        public void move() {             if (x + dx < 0 || x + BALL_SIZE + dx > WIDTH) {
                dx = -dx;
            }
            if (y + dy < 0 || y + BALL_SIZE + dy > HEIGHT) {
                dy = -dy;
            }             x += dx;             y += dy;
        }
        public void draw(Graphics g) {
            g.setColor(color);
            g.fillOval(x, y, BALL_SIZE, BALL_SIZE);
        }
    }
    private List<Ball> balls;
    public BouncingBalls() {         balls = new ArrayList<>();         for (int i = 0; i < 5; i++) {
            int startX = new Random().nextInt(WIDTH - BALL_SIZE);             int startY = new Random().nextInt(HEIGHT - BALL_SIZE);             int speedX = new Random().nextInt(MAX_SPEED) + 1;             int speedY = new Random().nextInt(MAX_SPEED) + 1;
            Color color = COLORS[i % COLORS.length];
            Ball ball = new Ball(startX, startY, speedX, speedY, color);             balls.add(ball);
            Thread thread = new Thread(() -> {
                while (true) {                     ball.move();                     repaint();                     try {
                        Thread.sleep(20);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            });
            thread.start();
        }
    }
    @Override     protected void paintComponent(Graphics g) {         super.paintComponent(g);
        for (Ball ball : balls) {             ball.draw(g);
        }
    }
    public static void main(String[] args) {
        JFrame frame = new JFrame("Bouncing Balls");         frame.setSize(WIDTH, HEIGHT);         frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);         frame.add(new BouncingBalls());         frame.setVisible(true);
    }
}
