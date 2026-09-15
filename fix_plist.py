import sys

path = 'ios/Runner/Info.plist'
with open(path, 'rb') as f:
    content = f.read()

# Try decoding ignoring errors
text = content.decode('utf-8', errors='ignore')

import re
# Replace the bad lines
text = re.sub(r'<string>Haritada konumunuzu.*?</string>', '<string>Haritada konumunuzu gosterebilmemiz icin konum iznine ihtiyacimiz var.</string>', text)
text = re.sub(r'<string>Size daha uygun reklamlar.*?</string>', '<string>Size daha uygun reklamlar gosterebilmemiz icin takip izni gereklidir.</string>', text)

with open(path, 'wb') as f:
    f.write(text.encode('utf-8'))
