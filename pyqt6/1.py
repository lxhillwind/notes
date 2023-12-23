import io
from PyQt6 import uic
from PyQt6.QtWidgets import QApplication
from PyQt6.QtCore import Qt

# the content is from ./1.ui, which is created by Qt6 Designer.
# NOTE: the first char should be "<" (instead of an whitespace / newline),
# to avoid xml parsing error?
uic_content = r'''<?xml version="1.0" encoding="UTF-8"?>
<ui version="4.0">
 <class>MainWindow</class>
 <widget class="QMainWindow" name="MainWindow">
  <property name="geometry">
   <rect>
    <x>0</x>
    <y>0</y>
    <width>800</width>
    <height>600</height>
   </rect>
  </property>
  <property name="windowTitle">
   <string>MainWindow</string>
  </property>
  <widget class="QWidget" name="centralwidget">
   <widget class="QPlainTextEdit" name="plainTextEdit">
    <property name="geometry">
     <rect>
      <x>170</x>
      <y>210</y>
      <width>104</width>
      <height>70</height>
     </rect>
    </property>
   </widget>
   <widget class="QPlainTextEdit" name="plainTextEdit_2">
    <property name="geometry">
     <rect>
      <x>450</x>
      <y>210</y>
      <width>104</width>
      <height>70</height>
     </rect>
    </property>
   </widget>
   <widget class="QPushButton" name="pushButton">
    <property name="geometry">
     <rect>
      <x>330</x>
      <y>240</y>
      <width>80</width>
      <height>27</height>
     </rect>
    </property>
    <property name="text">
     <string>繁体 -&gt; 简体</string>
    </property>
   </widget>
  </widget>
  <widget class="QStatusBar" name="statusbar"/>
 </widget>
 <resources/>
 <connections/>
</ui>
'''


app = QApplication([])
# uic.loadUi accepts filename or file-like object
#widget = uic.loadUi('./1.ui')
widget = uic.loadUi(io.StringIO(uic_content))

# sub widget name can be found in Qt Designer, or by inspecting 'name="' in xml
widget.pushButton.clicked.connect(lambda _: print('good'))

def handleKey(key):
    # enum is in PyQt6.QtCore.Qt
    if key.key() == Qt.Key.Key_Q:
        app.exit()

# name convention: Event.KeyPress => keyPressEvent
widget.pushButton.keyPressEvent = handleKey

widget.show()

app.exec()
