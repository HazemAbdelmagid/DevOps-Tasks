import unittest

from app import app

class BasicTestCase(unittest.TestCase):

    def test_Home_page(self):
        tester = app.test_client(self)
        response = tester.get('/', content_type='html/text')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data, b'Welcome everyone to My Main page!')

    def test_Hi_page(self):
        tester = app.test_client(self)
        response = tester.get('/hi/', content_type='html/text')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data, b'What is your name?')


if __name__ == '__main__':
    unittest.main()
