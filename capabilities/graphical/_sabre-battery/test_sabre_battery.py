import unittest
from sabre_battery import request, parse_reply


class ProtocolTests(unittest.TestCase):
    def test_request(self):
        self.assertEqual(request(), bytes([8, 4] + [0] * 14 + [0x49]))

    def reply(self, level=45, charging=0):
        data = [8, 4, 0, 0, 0, 0, level, charging, 0x0F, 0xA0] + [0] * 6
        return bytes(data + [(0x55 - sum(data)) & 255])

    def test_valid(self):
        self.assertEqual(parse_reply(self.reply()),
                         {"percentage": 45, "charging": False, "voltage_mv": 4000})
        self.assertTrue(parse_reply(self.reply(100, 1))["charging"])
        self.assertEqual(parse_reply(self.reply(0))["percentage"], 0)

    def test_invalid(self):
        good = self.reply()
        for bad in (b"", good[:-1], good + b"\0", bytes([9]) + good[1:],
                    good[:-1] + bytes([good[-1] ^ 1]), self.reply(101)):
            self.assertIsNone(parse_reply(bad))


if __name__ == "__main__":
    unittest.main()
