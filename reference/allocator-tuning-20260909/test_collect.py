"""Exercise collection acceptance and corruption rejection without running Factor."""
import json, subprocess, sys, tempfile, unittest
from pathlib import Path

HERE=Path(__file__).resolve().parent
REL='reference/allocator-speed-crossarch-20260908'
ALLOCATORS=('linear-scan','greedy','backtracking','chordal')
class CollectionTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup)
        self.root=Path(self.temp.name)
        for label,source in [('baseline','a'*40),('candidate','b'*40)]:
            root=self.root/label;out=root/REL;out.mkdir(parents=True)
            for marker in ['.allocator-source-commit','.allocator-prepared-source-commit']:
                (root/marker).write_text(source+'\n')
            (out/'source-manifest.py').write_text('# Fixture manifest was supplied by the test.\n')
            manifest={'source_commit':source,'archive_base':source,'all_match':True,'files':{}}
            for name in ['source-expected.json','source-manifest.json']:
                (out/name).write_text(json.dumps(manifest))
            for mode,ordinals in [('check',[1]),('timing',[1,2])]:
                for ordinal in ordinals:
                    for allocator in ALLOCATORS:
                        name=f'tuning-{label}-{mode}-{allocator}-{ordinal}'
                        rows=[{'kind':'scope','source':source,'allocator':allocator,
                               'checked':mode=='check','words':['one','two'],
                               'options':{'rematerialize_constants':True,'backtracking_loop_spills':True,'gvn':False}},
                              {'kind':'compile'}]+[{'kind':'code'} for _ in range(12)]
                        rows += [{'kind':'runtime','word':str(word),'trial':trial,'instructions':10,
                                  'cpu_seconds':.01,'output':word}
                                 for word in range(26) for trial in ([-1] if mode=='check' else [-1,0,1,2])]
                        (out/(name+'.jsonl')).write_text(''.join(json.dumps(x)+'\n' for x in rows))
                        (out/(name+'.status.json')).write_text(json.dumps({'ok':True,'exit_code':0,
                            'source_commit':source,'final_value_verifier':mode=='check'}))
    def collect(self):
        return subprocess.run([sys.executable,str(HERE/'collect.py'),str(self.root/'baseline'),
            str(self.root/'candidate'),str(self.root/'result'),'--baseline-source','a'*40,
            '--candidate-source','b'*40,'--baseline-label','tuning-baseline',
            '--candidate-label','tuning-candidate'],capture_output=True,text=True)
    def mutate(self,change):
        path=self.root/'candidate'/REL/'tuning-candidate-timing-greedy-2.jsonl'
        rows=[json.loads(x) for x in path.read_text().splitlines()];change(rows)
        path.write_text(''.join(json.dumps(x)+'\n' for x in rows))
    def test_accepts_exact_matrix_with_input_label_mapping(self):
        result=self.collect();self.assertEqual(result.returncode,0,result.stderr)
        data=json.loads((self.root/'result'/'collection.json').read_text())
        self.assertEqual(data['measured_batches'],1248)
        self.assertEqual(data['attribution_measured_batches'],0)
        self.assertEqual(data['checked_batches'],208)
        self.assertEqual(len(list((self.root/'result').glob('*-timing-*.jsonl.gz'))),16)
        self.assertEqual(len(list((self.root/'result').glob('*-check-*.jsonl.gz'))),8)
    def test_rejects_missing_sample(self):
        self.mutate(lambda rows:rows.pop());self.assertNotEqual(self.collect().returncode,0)
    def test_rejects_changed_answer(self):
        self.mutate(lambda rows:rows[-1].update(output='wrong'));self.assertNotEqual(self.collect().returncode,0)
    def test_rejects_inactive_option(self):
        self.mutate(lambda rows:rows[0]['options'].update(rematerialize_constants=False));self.assertNotEqual(self.collect().returncode,0)
    def test_rejects_changed_frozen_word_sequence(self):
        self.mutate(lambda rows:rows[0].update(words=['two','one']));self.assertNotEqual(self.collect().returncode,0)
    def test_rejects_failed_counter(self):
        self.mutate(lambda rows:rows[-1].update(instructions=0));self.assertNotEqual(self.collect().returncode,0)

if __name__=='__main__':unittest.main()
