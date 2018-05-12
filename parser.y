%{
#include <cstdio>
#include <iostream>
#include <map>
#include <string>
#include <string.h>
#include <strings.h>
#include <math.h>
#include<vector>
#include<stack>
#include <sstream>
using namespace std;

// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

void yyerror(const char *s);
void generateTop();
void generateBottom();
int getIndex(string s);
void generate(string s);
void printCode();
string toString(int x);
void writeConstants (int type, double val,string s);
bool exist(string check);
map< string,pair<int,float> > sym;
map<string,int> indx;
int idx = 0;
int pc = 0;
vector<string> byteCode;
stack<int> stk;
stack<int> stk2;

%}

%union {
	int ival;
	float fval;
	char *sval;
    char *id_val;
    char assign;
}


%token INT FLOAT BOOLEAN
%token IF ELSE
%token FOR WHILE
%token ASSIGN
%left PLUS MINUS
%left MUL DIV
%token EQU NEQU
%token GRT SML
%token GTE LTE



%token <ival> INT_VAL
%token <fval> FLOAT_VAL
%token <sval> STRING
%token <id_val> ID
%type <ival> primitive_type
%type <fval> simple_expression
%type <fval> term
%type <fval> factor
%%



// Rule definition
method_body:{generateTop();}
    statement_list
    {
    printCode();
    generateBottom();};

statement_list:
    statement
    | statement_list statement
    ;
statement:
    declaration
    | if
    | while
    | assignment
    ;
declaration:
    primitive_type ID ';'{
        string s($2);
        sym.insert(make_pair($2,make_pair($1,0)));
        indx.insert(make_pair(s,++idx));
    }
    ;
primitive_type:
    INT{$$ = 0;}
    | FLOAT{$$ = 1;}
    ;
if:
    IF '(' expression ')' '{' statement {
            string s(toString(pc) + " : " +"got to\t");
            generate(s);
            pc += 3;
            byteCode[stk.top()-1] += toString(pc);
            stk.pop();
            stk.push(((int)byteCode.size())-1);
    }'}' ELSE '{' 
            statement {
                byteCode[stk.top()] += toString(pc);
                stk.pop();
            }
    '}'
    ;
while:
    WHILE '(' {
        stk2.push((int)byteCode.size()-1);
    }expression ')' '{' statement{
        byteCode[stk.top()-1] += toString(pc + 3);
        stk.pop();
        int number = 0;
        int ptr = 0;
        while(byteCode[stk2.top()][ptr] != ' '){
            number *= 10;
            number += (byteCode[stk2.top()][ptr++] - '0');
        }
        string ss(toString(pc) + " : got to " + toString(number));
        generate(ss);
        pc += 3;
        stk2.pop();
    }


     '}'
    ;
assignment:
    ID ASSIGN simple_expression ';' {
        string s($1);
        if(exist(s)){
            sym[s] =make_pair(sym[s].first,$3);
            writeConstants(sym[s].first,(double)$3,s);
           
        }else{
            string s("variable not defined");
            yyerror(s.c_str());
        }
    }
    ;
expression:
    simple_expression EQU simple_expression {
            string s(toString(pc) + " : " + "if_icmpne\t");    
            generate(s);
            stk.push((int)byteCode.size());
            pc += 3;

    }
    | simple_expression NEQU simple_expression{
        string s("if_icmpeq\t");  
        generate(s);
        stk.push((int)byteCode.size());  
        pc += 3;
        
    }
    | simple_expression GRT simple_expression{
            string s(toString(pc) + " : " + "if_icmple\t");    
            generate(s);
            stk.push((int)byteCode.size());
            pc += 3;
          
    }
    | simple_expression SML simple_expression{

        string s(toString(pc) + " : " + "if_icmpge\t");   
        generate(s);
        stk.push((int)byteCode.size()); 
        pc += 3;
           

    }
    | simple_expression GTE simple_expression{
           string s(toString(pc) + " : " + "if_icmplt\t"); 
           generate(s);
           stk.push((int)byteCode.size());  
           pc += 3; 
           
    }
    | simple_expression LTE simple_expression{
        string s(toString(pc) + " : " + "if_icmpgt\t");   
        generate(s);
        stk.push((int)byteCode.size()); 
        pc += 3;
          
    }

    ;
simple_expression:
    term{
        $$ = $1;
    }
    | simple_expression PLUS term {
        $$ = $1 + $3;
    }
    | simple_expression MINUS term{
        $$ = $1 - $3;
    }
    ;
term:
    factor{
        $$ = $1;
    }
    | term MUL factor{
        $$ = $1 * $3;
    }
    | term DIV factor{
        if($3 == 0){
            string s("divison by zero error");
            yyerror(s.c_str());
        }
        $$ = $1 / $3;
    }
    ;
factor:
    ID{
        string s($1);
        $$ = sym[s].second;
    }
    | INT_VAL
    | FLOAT_VAL
    ;

%%

int main(int, char**) {
    freopen("input_program.txt", "r", stdin);
    freopen("output_program.txt", "w", stdout);
    yyparse();
}

void yyerror(const char* s) {
	cout << "Error tookplace"<< endl;
	exit(-1);
}
void generateTop(){
 
    
        std::cout << (".class public ByteCodeGenerator") << endl;
        std::cout << (".super java/lang/Object") << endl;
        std::cout << (".method public <init>()V") << endl;
        std::cout << ("aload_0") << endl;
        std::cout << ("invokenonvirtual java/lang/Object/<init>()V") << endl;
        std::cout << ("return") << endl;
        std::cout << (".end method") << endl;
        std::cout << (".method public static main([Ljava/lang/String;)V") << endl;
        std::cout << (".limit locals 100") << endl;
        std::cout << (".limit stack 100") << endl;
}
void generateBottom(){
    std::cout << toString(pc)<<(" : return") << endl;
    std::cout << (".end method") << endl;
}

void writeConstants (int type, double val,string variableName)
{

        

        if(type == 1)
        {

            string s(toString(pc) + " : " + "ldc\t" + toString(val));
            std::cout << pc<<" : "<<"ldc\t";
            if (val == (int)val)
                s += ".0";
            generate(s);
            s = "";
            pc += 2;
            s += toString(pc);
            s += " : fstore    ";
            s += toString(getIndex(variableName));
            generate(s);      
            pc += 2;
        }
        else
        {
            int value = (int)val;
            if( 0 <= value && value <= 5 )
            {
                string s(toString(pc) + " : iconst_"+toString(value));
                generate(s);
                s = "";
                pc += 1;
                string ss(toString(pc) + " : istore_"+toString(getIndex(variableName)));
                generate(ss);
                pc += 1;

            }
            else if( -128 <= value && value <= 127 )
            {


                string s(toString(pc) + " : bipush  "+toString(value));
                generate(s);
                s = "";
                pc += 2;
                string ss(toString(pc) + " : istore_"+toString(getIndex(variableName)));
                generate(ss);
                pc += 2;

            }
            else if( -32768 <= value && value <= 32767 )
            {


                string s(toString(pc) + " : sipush  "+toString(value));
                generate(s);
                s = "";
                pc += 2;
                string ss(toString(pc) + " : istore_"+toString(getIndex(variableName)));
                generate(ss);
                pc += 2;

            }
            else
            {

                string s(toString(pc) + " : ldc\t"+toString(value));
                generate(s);
                s = "";
                pc += 2;
                string ss(toString(pc) + " : istore_"+toString(getIndex(variableName)));
                generate(ss);
                pc += 2;
            }
        }
       
}

int getIndex(string s){
    return indx.find(s)->second;
}
void printCode(){
    for(int i = 0 ; i < (int)byteCode.size();++i){
        cout<<byteCode[i]<<endl;
    }
}
bool exist(string check){
    return sym.find(check) != sym.end();
}

void generate(string s){
    byteCode.push_back(string(s));
}

string toString(int x){
    stringstream s;
    s << x;
    return s.str();
}

