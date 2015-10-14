import 'core/test.sol';
import 'ens.sol';
import 'user.sol';

contract ENSTester is ENSUser {
    function ENSTester(ENS app)
    {
        init_usermock(app);
    }
    function do_set( address node, bytes32 key, bytes32 value ) returns (bool ok) {
        return ens.set( node, key, value );
    }
    function do_get( address node, bytes32 key ) returns (bytes32 value, bool ok) {
        value = ens.get( node, key );
        ok = ens.last_ok();
    }
    function do_freeze( address node, bytes32 key ) returns (bool ok) {
        return ens.freeze(node, key);
    }
}

contract ENSTest is Test {
    ENS ens;
    ENS_Controller_CuratedNamereg root;
    ENSTester A;
    function setUp() {
        root = new ENS_Controller_CuratedNamereg();
        ens = new ENS( address( root ) );
        A = new ENSTester( ens );
        root.ens_controller_init( A );
        root.init_usermock(ens);
        A.do_set(root, "key", "value");
    }
    function testRootNodeConfigured() {
        assertEq( root, address(ens.root()), "wrong root controller");
        assertEq( A, root.owner(), "wrong root controller owner" );
    }
    function testRootNodeController() {
        assertEq32("value", root.ens_get("key"), "controller gets wrong key");
        assertEq32("value", ens.get(root, "key"), "app gets wrong key");

        assertTrue( A.do_set(root, "key", "value2"), "can't re-set key" );
        assertEq32( "value2", ens.get(root, "key"), "wrong value after set" );
        assertTrue( A.do_freeze( root, "key" ), "can't freeze key" );
        assertEq32( "value2", ens.get(root, "key"), "wrong value after set attempt" );
    }
    function testResolve() {
        bytes32 ret = ens.get( root, "axsdfasdfasdfasdsdfasdf");
        log_bytes32(ret);
    }
    function testCuratedNameregGet()
             logs_gas()
    {
        ens.get(root, "key");
    }
    function testCuratedNameregSet()
             logs_gas()
    {
        ens.set(root, "key", "value");
    }
}