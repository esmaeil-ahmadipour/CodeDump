import os, sys, json, shutil, tempfile, unittest, builtins
from unittest import mock
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import code_dump as cd


class T(unittest.TestCase):
    def setUp(self):
        self.d = tempfile.mkdtemp()
        self.cfg = os.path.join(self.d, "settings.json")
        os.makedirs(os.path.join(self.d, "code/node_modules"))
        for n, c in {"code/a.py": "print(1)", "code/b.weird": "x", "code/node_modules/z.js": "n"}.items():
            open(os.path.join(self.d, n), "w").write(c)
        open(os.path.join(self.d, "code/bin.dat"), "wb").write(b"\x00\x01\x02")

    def tearDown(self):
        shutil.rmtree(self.d)

    def run_cli(self, *a):
        return cd.main(["-c", self.cfg, *a])

    def test_empty_settings_restored(self):
        open(self.cfg, "w").close()
        s = cd.load_settings(self.cfg)
        self.assertEqual(s["defaults"]["only_extensions"], [])
        self.assertEqual(json.load(open(self.cfg))["version"], cd.VERSION)

    def test_broken_settings_backed_up(self):
        open(self.cfg, "w").write("{oops")
        cd.load_settings(self.cfg)
        self.assertTrue(os.path.exists(self.cfg + ".bak"))

    def test_all_types_when_no_filter(self):
        out = os.path.join(self.d, "r.txt")
        self.assertEqual(self.run_cli(os.path.join(self.d, "code"), "-o", out), 0)
        t = open(out, encoding="utf-8").read()
        self.assertIn("b.weird", t); self.assertIn("a.py", t)
        self.assertNotIn("bin.dat", t); self.assertNotIn("z.js", t)

    def test_extension_filter_and_old_keys(self):
        json.dump({"enabled": True, "global": {"include_extensions": ["py"]},
                   "projects": [{"name": "P", "path": "./code"}]}, open(self.cfg, "w"))
        self.assertEqual(self.run_cli("--all"), 0)
        t = open(os.path.join(self.d, "code_report_P.txt"), encoding="utf-8").read()
        self.assertIn("a.py", t); self.assertNotIn("b.weird", t)
        self.assertTrue(os.path.isdir(os.path.join(self.d, "backup")))

    def test_project_override(self):
        s = cd.default_settings()
        s["projects"] = [{"name": "P", "path": "./code", "active": True,
                          "overrides": {"only_extensions": [".weird"]}}]
        cd.save_settings(s, self.cfg)
        self.run_cli("-p", "P")
        t = open(os.path.join(self.d, "code_report_P.txt"), encoding="utf-8").read()
        self.assertIn("b.weird", t); self.assertNotIn("a.py", t)

    def test_menu_changes_setting(self):
        s = cd.load_settings(self.cfg)
        keys = list(cd.SPEC)
        n = str(keys.index("show_tree") + 1)
        with mock.patch.object(builtins, "input", side_effect=[n, "0"]):
            cd.settings_menu(s, self.cfg)
        self.assertFalse(json.load(open(self.cfg))["defaults"]["show_tree"])

    def test_split(self):
        o = cd.project_options(cd.default_settings()); o["split_tokens"] = 1
        files = [("a", 10, "x" * 40), ("b", 10, "y" * 40)]
        self.assertGreater(len(cd.build_report("n", "r", files, o)), 1)

    def test_self_output_excluded(self):
        out = os.path.join(self.d, "code", "out.txt")
        self.run_cli(os.path.join(self.d, "code"), "-o", out)
        self.run_cli(os.path.join(self.d, "code"), "-o", out)
        self.assertEqual(open(out, encoding="utf-8").read().count("FILE:  out.txt"), 0)


if __name__ == "__main__":
    unittest.main()
