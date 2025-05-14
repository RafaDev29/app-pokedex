import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(AppPokedex());

class AppPokedex extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Console',
        primaryColor: Color(0xFFE3350D),
        scaffoldBackgroundColor: Color(0xFFE3350D),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? data;
  bool isLoading = false;
  String error = '';
  bool isPokedexOpen = false;

  late final AnimationController _pokeballController;
  
  @override
  void initState() {
    super.initState();
    _pokeballController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pokeballController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> getPokemon(String name) async {
    setState(() {
      isLoading = true;
      error = '';
      data = null;
    });

    final url = 'https://yi1exr7v9g.execute-api.us-east-2.amazonaws.com/pokemon';

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name.toLowerCase()}),
      );

      if (res.statusCode == 200) {
        final result = jsonDecode(res.body);
        setState(() {
          data = result;
          isPokedexOpen = true;
        });
      } else {
        setState(() {
          error = 'Pokémon no encontrado';
          isPokedexOpen = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error de conexión';
        isPokedexOpen = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Color getTypeColor(String type) {
 
    final typeColors = {
      'normal': Color(0xFFA8A878),
      'fuego': Color(0xFFF08030),
      'agua': Color(0xFF6890F0),
      'electrico': Color(0xFFF8D030),
      'planta': Color(0xFF78C850),
      'hielo': Color(0xFF98D8D8),
      'lucha': Color(0xFFC03028),
      'veneno': Color(0xFFA040A0),
      'tierra': Color(0xFFE0C068),
      'volador': Color(0xFFA890F0),
      'psiquico': Color(0xFFF85888),
      'bicho': Color(0xFFA8B820),
      'roca': Color(0xFFB8A038),
      'fantasma': Color(0xFF705898),
      'dragon': Color(0xFF7038F8),
      'siniestro': Color(0xFF705848),
      'acero': Color(0xFFB8B8D0),
      'hada': Color(0xFFEE99AC),
    };
    
    return typeColors[type.toLowerCase()] ?? Colors.grey;
  }

  Widget buildTypeBadge(String type) {
    return Container(
      margin: EdgeInsets.only(right: 5, bottom: 5),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: getTypeColor(type),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildStatBar(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Container(
                    height: 8,
                    width: (value / 255) * MediaQuery.of(context).size.width * 0.3,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 5),
            Text(
              value.toString(),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 4),
      ],
    );
  }

  Widget buildPokedexClosed() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _pokeballController,
            child: Container(
              height: 100,
              width: 100,
             
              child: Image.asset(
                'assets/pokeball.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 40),
          Text(
            "POKÉDEX",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 5,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Nombre del Pokémon',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    final name = _controller.text.trim();
                    if (name.isNotEmpty) getPokemon(name);
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFFE3350D),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  error,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildPokedexOpen() {
    if (data == null) return SizedBox.shrink();
    
    return Column(
      children: [
        // Cabecera de la Pokédex
        Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: Color(0xFFE3350D),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "POKÉDEX",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Imagen y número
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "#${data!['id'].toString().padLeft(3, '0')}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFFE3350D),
                          ),
                        ),
                        Row(
                          children: List<Widget>.from(
                            (data!['types'] as List).map(
                              (type) => buildTypeBadge(type),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 200,
                      child: Hero(
                        tag: 'pokemon-${data!['id']}',
                        child: Image.network(
                          data!['image'],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 100,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Información del Pokémon
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data!['name_es'].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE3350D),
                      ),
                    ),
                    SizedBox(height: 5),
                  
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoBox("ALTURA", "${data!['height']} m"),
                        _buildInfoBox("PESO", "${data!['weight']} kg"),
                        _buildInfoBox("HABILIDAD", data!['ability'], flexbox: true),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      "ESTADÍSTICAS",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE3350D),
                      ),
                    ),
                    SizedBox(height: 10),
                    buildStatBar("HP", data!['stats']['hp'], Colors.red),
                    buildStatBar("ATAQUE", data!['stats']['attack'], Colors.orange),
                    buildStatBar("DEFENSA", data!['stats']['defense'], Colors.blue),
                    buildStatBar("ATAQUE ESP.", data!['stats']['special-attack'], Colors.purple),
                    buildStatBar("DEFENSA ESP.", data!['stats']['special-defense'], Colors.teal),
                    buildStatBar("VELOCIDAD", data!['stats']['speed'], Colors.green),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              isPokedexOpen = false;
              _controller.clear();
            });
          },
          icon: Icon(Icons.arrow_back),
          label: Text("VOLVER"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoBox(String label, String value, {bool flexbox = false}) {
    return Flexible(
      child: Container(
        width: flexbox ? null : 100,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 8,  // Tamaño reducido
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 10,  // Tamaño reducido
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.all(10),
          child: isPokedexOpen ? buildPokedexOpen() : buildPokedexClosed(),
        ),
      ),
    );
  }
}