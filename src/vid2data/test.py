section = (b"#" * 2000) + (b"\0" * 48)
data = b""

for _ in range(16):
    data += section

with open("build/data.bin", "wb") as file:
    file.write(data)