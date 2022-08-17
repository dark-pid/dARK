// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract NoidProvider {
    
    // nice opaque identifier - NOId
    // https://metacpan.org/dist/Noid/view/noid

    

    // TODO: Passar como parametro
    string alphabet_raw = "0123456789bcdfghjkmnpqrstvwxz";
    uint8 alphabet_len = 29; //0-28
    
    // dados do alfabeto
    bytes alphabet;
    mapping(bytes1 => uint8) private map_alphabet;
    
    // Dados do dono
    bytes nam;
    bytes dnam;
    bytes sec_nam;
    bytes1 sep_token;

    address private owner;
    
    // noid util
    uint8 noid_len;
    uint8[] noid_gen_index;

    //
    uint contador = 0;
    bool configured = false;
    bool full = false;



    constructor() {
        //usar para controle de acesso
        //TODO: CRIAR SET OWNER COM O CONTROLE DE ACESSO
        owner = msg.sender;
    }


    // configurar
    // secnam e o separador
    function configure(uint8 tamanho,
                       string memory _nam, 
                       string memory dnam_id, 
                       string memory secnam_id,
                       string memory _sep_token)
    public {
        require(configured == false,"noid already configured");

        nam = bytes(_nam);

        noid_len = tamanho;
        noid_gen_index = new uint8[](tamanho);
        configured = true;

        for (uint8 i=0; i<tamanho ; i++ ){
            noid_gen_index[i] = 0;
        }

        //configuração do alfabeto
        alphabet = bytes(alphabet_raw);

        for (uint8 i=0; i<alphabet_len; i++ ){
            map_alphabet[alphabet[i]] = i;
        }

        dnam = bytes(dnam_id);
        sec_nam = bytes(secnam_id);
        sep_token = bytes1(bytes(_sep_token));
        
    }
    
    ////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////
    //
    // nice opaque identifier - NOId
    // https://metacpan.org/dist/Noid/view/noid 
    //
    ////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////

    
    function gen() public returns (string memory noid){

        bytes memory partial_noid = bytes(create_partial_id());
        string memory noid_no_dv = string(abi.encodePacked(nam,bytes("/"),
                                            dnam, sec_nam , sep_token ,bytes(partial_noid)));

        noid = noid_ncda(noid_no_dv);
        // return (noid);
    }


    function create_partial_id() private returns (string memory partial_noid) {

        
        require(!full,"noid is full!");
        bytes memory partial_id = new bytes(noid_len);
        iterate();

        for (uint i=0; i < noid_len; i++) {
            uint8 c = noid_gen_index[i];
            bytes1 bchar = bytes(get_char_at(c))[0];
            partial_id[i] = bchar;
        }

        return string(partial_id);
    }



    
    /// UTIL
    function iterate() private {
        
        require(!full,"noid is full!");
        uint8 dim = uint8(noid_len -1);

        for (uint8 i=0; i < noid_len; i++) {
            uint8 pos = dim - i;
            uint local_val = noid_gen_index[pos];

            if (local_val < (alphabet_len - 1) ){
                noid_gen_index[pos] = uint8(local_val + 1);
                break;
            } else if (local_val == (alphabet_len - 1) ){
                noid_gen_index[pos] = 0;

                if (i == (noid_len - 1)){
                    full = true;
                }
            }
        }
        require(!full,"noid is full!");
        contador++;
    }

    //
    function count() public view 
    returns (uint id_gerados)
    {
        return contador;
    }
    

    ////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////
    // Noid Check Digit Algorithm  (NCDA)
    // https://metacpan.org/dist/Noid/view/noid#RULE-BASED-MAPPING
    // 
    ////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////


    //  * @dev get the char at a position
    //  * @param position of char
    //  * @return the character
    function get_char_at(uint8 pos) 
    private view
    returns (string memory char_at_pos) {
        bytes1 symbol = alphabet[pos];
        return string(abi.encodePacked(symbol));
    }


    // @dev get the position of char in the alphabet
    // @param character
    // @return postion of the character, if charater isnt in 
    // the map the method return 0
    function get_char_pos(string memory char) 
    private view
    returns (uint8 pos) {
        require(bytes(char).length == 1,"use only onde char");
        bytes1 x = bytes(char)[0];
        uint8 _pos = map_alphabet[x];
        
        // if want distinquis the first 
        // if x != bytes(first_token)[0]{
        //     _pos = -1;
        // }
        return _pos;
    }

    function get_char_pos(bytes1 char) 
    private view
    returns (uint8 pos) {
        uint8 _pos = map_alphabet[char];
        return _pos;
    }

    // https://gist.github.com/ageyev/779797061490f5be64fb02e978feb6ac
    // 13030/xf93gt2

    function noid_ncda(string memory id) 
    public view
    returns (string memory output) {
        
        bytes memory bid = bytes(id);


        uint256 val = 0;
        for (uint i=0; i<bid.length; i++ ){
            bytes1 _char = bid[i];
            uint prod = (i + 1) * get_char_pos(_char);
            val = val + prod;
        }

        string memory _vd = get_char_at(uint8(val % alphabet_len));
        // output = 

        return string(abi.encodePacked(id, _vd));
    }

}