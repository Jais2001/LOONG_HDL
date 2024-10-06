from PyQt5.QtCore import Qt
import serial
import serial.tools.list_ports
import sys
from PyQt5.QtWidgets import QApplication,QComboBox,QMainWindow, QWidget,QVBoxLayout,QHBoxLayout,QLabel,QLineEdit,QPushButton
from PyQt5.QtGui import QFont
class Uart_loong(QMainWindow):
    ports = serial.tools.list_ports.comports()
    SerialInst = serial.Serial()
    cipherkey = "0"
    plaintxt = "0"
    def __init__(self):
        super().__init__()
        self.start_gui()
    def start_gui(self):
        self.setWindowTitle("LOONG_GUI")
        self.setStyleSheet('background-color:#2a2a2a')
        self.setMinimumSize(1700,800)
        self.font = QFont()
        self.font.setBold(True)
        self.font.setPointSize(10)

        central_widget = QWidget(self)
        self.setCentralWidget(central_widget)

        central_layout = QVBoxLayout(central_widget)

        main_layout0 = QHBoxLayout()
        main_layout1 = QHBoxLayout()
        main_layout2 = QHBoxLayout()
        main_layout3 = QHBoxLayout()
        main_layout4 = QHBoxLayout()

        main_layout2_sub1 = QHBoxLayout()
        main_layout2_sub2 = QHBoxLayout()
        main_layout2_sub3 = QHBoxLayout()


        central_layout.addLayout(main_layout0)
        central_layout.addLayout(main_layout1)
        central_layout.addLayout(main_layout2)
        central_layout.addLayout(main_layout3)
        central_layout.addLayout(main_layout4)

        main_layout2.addLayout(main_layout2_sub1)
        main_layout2.addLayout(main_layout2_sub2)
        main_layout2.addLayout(main_layout2_sub3)

        self.label_main = QLabel()
        self.label_main.setText("                    LOONG")
        self.label_main.setStyleSheet('color: white')
        self.label_main.setFixedSize(500,100)
        font = self.label_main.font()
        font.setPointSize(20) 
        self.label_main.setFont(font)
        main_layout0.addWidget(self.label_main)

        label_space = QLabel()
        label_space.setText("          ")
        # label1.setFixedSize(500,100)
        font = label_space.font()
        font.setPointSize(120) 
        label_space.setFont(font)
        main_layout1.addWidget(label_space)

        self.label8 = QLabel()
        self.label8.setText("Select your USB Port : ")
        self.label8.setFont(self.font)
        main_layout1.addWidget(self.label8)
        # self.label8.setAlignment(Qt.AlignRight)
        self.label8.setStyleSheet('color: blue')

        self.com_combobox = QComboBox()
        self.com_combobox.setFont(self.font)
        self.com_combobox.setFixedSize(200,30)
        self.com_combobox.addItem("Select your Port")
        # self.com_combobox.addItems(myports)
        self.com_combobox.setStyleSheet('color: black;background-color : white')
        main_layout1.addWidget(self.com_combobox)
        # self.com_combobox.currentIndexChanged.connect(self.onclick_Entr_Com)

        label_spce = QLabel()
        label_spce.setText("          ")
        # label1.setFixedSize(500,100)
        font = label_spce.font()
        font.setPointSize(120) 
        label_spce.setFont(font)
        main_layout1.addWidget(label_spce)
    
        label1 = QLabel()
        label1.setText("          ")
        # label1.setFixedSize(500,100)
        font = label1.font()
        font.setPointSize(20) 
        label1.setFont(font)
        main_layout2_sub1.addWidget(label1)

        self.label3= QLabel()
        self.label3.setFont(self.font)
        self.label3.setText("PLAINTEXT:")
        main_layout2_sub1.addWidget(self.label3)
        self.label3.setStyleSheet('color: blue')

        self.tedit2 = QLineEdit()
        self.tedit2.setStyleSheet('color: black;background-color : white')
        self.tedit2.setFont(self.font)
        main_layout2_sub1.addWidget(self.tedit2)

        label = QLabel()
        label.setText("          ")
        # label.setFixedSize(10,10)
        font = label.font()
        font.setPointSize(50) 
        label.setFont(font)
        main_layout2_sub1.addWidget(label)

        self.mybutton = QPushButton(' Enter ')
        # self.mybutton.setCheckable(True)
        self.mybutton.setFixedSize(300, 30)
        self.mybutton.setStyleSheet("QPushButton { background-color: blue;}")
        self.mybutton.setFont(self.font)
        self.mybutton.clicked.connect(self.send_text_key)
        main_layout3.addWidget(self.mybutton)

        label1 = QLabel()
        label1.setText("          ")
        # label1.setFixedSize(500,100)
        font = label1.font()
        font.setPointSize(50) 
        label1.setFont(font)
        main_layout2_sub3.addWidget(label1)

        self.label4= QLabel()
        self.label4.setFont(self.font)
        self.label4.setText("CIPHERKEY:")
        main_layout2_sub3.addWidget(self.label4)
        self.label4.setStyleSheet('color: blue')

        self.tedit1 = QLineEdit()
        self.tedit1.setStyleSheet('color: black;background-color : white')
        self.tedit1.setFont(self.font)
        main_layout2_sub3.addWidget(self.tedit1)

        label1 = QLabel()
        label1.setText("          ")
        # label1.setFixedSize(500,100)
        font = label1.font()
        font.setPointSize(20) 
        label1.setFont(font)
        main_layout2_sub3.addWidget(label1)

        label0 = QLabel()
        label0.setText("          ")
        # label1.setFixedSize(500,100)
        font = label0.font()
        font.setPointSize(120) 
        label0.setFont(font)
        main_layout4.addWidget(label0)

        self.label5= QLabel()
        self.label5.setFont(self.font)
        self.label5.setText("CIPHERTEXT:")
        main_layout4.addWidget(self.label5)
        self.label5.setStyleSheet('color: blue')

        self.tedit = QLineEdit()
        self.tedit.setStyleSheet('color: black;background-color : white')
        self.tedit.setFont(self.font)
        self.tedit.setFixedSize(300, 30)
        main_layout4.addWidget(self.tedit)

        label7 = QLabel()
        label7.setText("          ")
        # label1.setFixedSize(500,100)
        font = label7.font()
        font.setPointSize(120) 
        label7.setFont(font)
        main_layout4.addWidget(label7)

    def send_text_key(self):
        self.plaintxt = self.tedit2.text()
        self.cipherkey = self.tedit1.text()
        self.plaintxt_cipher = self.plaintxt + self.cipherkey
        print(self.plaintxt_cipher)
        # Uart_loong.SerialInst.write(self.plaintxt_cipher.encode('utf'))

def main():
   app = QApplication(sys.argv)
   window = Uart_loong()
   window.show()
   sys.exit(app.exec_())

if __name__ == '__main__':
   main()