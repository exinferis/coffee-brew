package org.coffeebrew.lang.lexer;


import com.intellij.lexer.FlexLexer;
import com.intellij.psi.tree.IElementType;
import org.coffeebrew.lang.lexer.CoffeeScriptTokenTypes;
import java.util.Stack;

%%

%debug

%unicode

%public
%class CoffeeScriptLexer
%implements FlexLexer
%type IElementType

%function advance

%{

  private IElementType characterClassType;

  private final Stack<Integer> stack = new Stack<Integer>();

  /**
   * Push the actual state on top of the stack
   */
  private void pushState() {
    stack.push(yystate());
  }

  /**
   * Push the actual state on top of the stack
   * and change into another state
   *
   * @param state The new state
   */
  private void pushStateAndBegin(int state) {
    stack.push(yystate());
    yybegin(state);
  }

  /**
   * Pop the last state from the stack and change to it
   *
   * @return the stack it has changed into
   */
  private int popState() {
    if (!stack.empty()) {
      final int state = stack.pop();
      yybegin(state);
      return state;
    }

    return -1;
  }

  /**
   * Push the stream back to the position before the text match
   *
   * @param text The text to match
   * @return true when matched
   */
  private boolean pushBackTo(String text) {
    final int position = yytext().toString().indexOf(text);

    if (position != -1) {
      yypushback(yytext().length() - position);
      return true;
    }

    return false;
  }

  /**
   * Push the stream back to the position before the text match
   * and change into the given state
   *
   * @param text The text to match
   * @param state The new state
   * @return true when matched
   */
  private boolean pushBackAndState(String text, int state) {
    final boolean success = pushBackTo(text);

    if (success) {
      pushStateAndBegin(state);
    }

    return success;
  }

%}

TERMINATOR          = [\n\r;]|\\\n
WHITE_SPACE          = [\ ]+
IDENTIFIER          = [a-zA-Z\$_]([a-zA-Z_0-9$])*
NUMBER              = (0(x|X)[0-9a-fA-F]+)|(-?[0-9]+(\.[0-9]+)?(e[+\-]?[0-9]+)?)
DOUBLE_QUOTE_STRING = (\\.|[^\"\n\r])*
SINGLE_QUOTE_STRING = (\\.|[^\'\n\r])*
LINE_COMMENT        = #[^\n\r{]+
BLOCK_COMMENT       = ###~###
JAVASCRIPT          = [^`]+
REGEX               = [^/\\\r\n\[\]\(\)\{\}]+

THIS            = @|this
RESERVED        = case|default|function|var|void|with|const|let|enum|export|import|native|__hasProp|__extends|__slice|__bind|__indexOf
LOGIC           = and|&&|or|\|\||&|\||\^|\?
COMPARE         = ==|\!=|<|>|<=|>=|is|isnt
COMPOUND_ASSIGN = -=|\+=|\/=|\*=|%=|\|\|=|&&=|\?=|<<=|>>=|>>>=|&=|\^=|\|=|or=
BOOL            = true|yes|on|false|no|off|undefined|null
UNARY           = do|new|typeof|delete|\~|\!|not

%state YYIDENTIFIER, YYNUMBER, YYJAVASCRIPT
%state YYDOUBLEQUOTESTRING, YYSINGLEQUOTESTRING
%state YYDOUBLEQUOTEHEREDOC, YYSINGLEQUOTEHEREDOC
%state YYREGEX, YYHEREGEX, YYREGEXFLAG, YYREGEXCHARACTERCLASS
%state YYINTERPOLATION

%%

<YYINITIAL> {
  {RESERVED}                  { return CoffeeScriptTokenTypes.ERROR_ELEMENT; }

  {THIS}                      { return CoffeeScriptTokenTypes.THIS; }

  "class"                     { return CoffeeScriptTokenTypes.CLASS; }
  "extends"                   { return CoffeeScriptTokenTypes.EXTENDS; }
  "try"                       { return CoffeeScriptTokenTypes.TRY; }
  "catch"                     { return CoffeeScriptTokenTypes.CATCH; }
  "finally"                   { return CoffeeScriptTokenTypes.FINALLY; }
  "throw"                     { return CoffeeScriptTokenTypes.THROW; }
  "if"                        { return CoffeeScriptTokenTypes.IF; }
  "then"                      { return CoffeeScriptTokenTypes.THEN; }
  "else"                      { return CoffeeScriptTokenTypes.ELSE; }
  "unless"                    { return CoffeeScriptTokenTypes.UNLESS; }
  "for"                       { return CoffeeScriptTokenTypes.FOR; }
  "in"                        { return CoffeeScriptTokenTypes.IN; }
  "of"                        { return CoffeeScriptTokenTypes.OF; }
  "by"                        { return CoffeeScriptTokenTypes.BY; }
  "while"                     { return CoffeeScriptTokenTypes.WHILE; }
  "until"                     { return CoffeeScriptTokenTypes.UNTIL; }
  "switch"                    { return CoffeeScriptTokenTypes.SWITCH; }
  "when"                      { return CoffeeScriptTokenTypes.WHEN; }
  "break"                     { return CoffeeScriptTokenTypes.BREAK; }
  "continue"                  { return CoffeeScriptTokenTypes.CONTINUE; }
  "return"                    { return CoffeeScriptTokenTypes.RETURN; }
  "instanceof"                { return CoffeeScriptTokenTypes.INSTANCE_OF; }

  {BOOL}                      { return CoffeeScriptTokenTypes.BOOL; }
  {LOGIC}                     { return CoffeeScriptTokenTypes.LOGIC; }
  {COMPARE}                   { return CoffeeScriptTokenTypes.COMPARE; }
  {COMPOUND_ASSIGN}           { return CoffeeScriptTokenTypes.COMPOUND_ASSIGN; }
  {UNARY}                     { return CoffeeScriptTokenTypes.UNARY; }

  \"                          { yybegin(YYDOUBLEQUOTESTRING);
                                return CoffeeScriptTokenTypes.STRING_LITERAL; }

  \'                          { yybegin(YYSINGLEQUOTESTRING);
                                return CoffeeScriptTokenTypes.STRING_LITERAL; }

  "\"\"\""                    { yybegin(YYDOUBLEQUOTEHEREDOC);
                                return CoffeeScriptTokenTypes.HEREDOC_START; }

  "'''"                       { yybegin(YYSINGLEQUOTEHEREDOC);
                                return CoffeeScriptTokenTypes.HEREDOC_START; }

  "`"                         { yybegin(YYJAVASCRIPT);
                                return CoffeeScriptTokenTypes.JAVASCRIPT_LITERAL; }

  {IDENTIFIER}                { yybegin(YYIDENTIFIER);
                                return CoffeeScriptTokenTypes.IDENTIFIER; }

  {NUMBER}                    { yybegin(YYNUMBER);
                                return CoffeeScriptTokenTypes.NUMBER; }


  "->"                        { return CoffeeScriptTokenTypes.FUNCTION; }
  "=>"                        { return CoffeeScriptTokenTypes.FUNCTION_BIND; }

  "="                         { return CoffeeScriptTokenTypes.EQUAL; }

  "["                         { return CoffeeScriptTokenTypes.BRACKET_START; }
  "]"                         { return CoffeeScriptTokenTypes.BRACKET_END; }

  "("                         { return CoffeeScriptTokenTypes.PARENTHESIS_START; }
  ")"                         { return CoffeeScriptTokenTypes.PARENTHESIS_END; }

  /* Push the state because the braces are important for determining the interpolation */
  "{"                         { pushState();
                                return CoffeeScriptTokenTypes.BRACE_START; }

  "}"                         { final int state = popState();
                                if (state == YYINITIAL) {
                                  return CoffeeScriptTokenTypes.BRACE_END;
                                } else {
                                  yypushback(1);
                                }
                              }

  "."                         { return CoffeeScriptTokenTypes.DOT; }
  ":"                         { return CoffeeScriptTokenTypes.COLON; }
  ","                         { return CoffeeScriptTokenTypes.COMMA; }

  "+"                         { return CoffeeScriptTokenTypes.PLUS; }
  "-"                         { return CoffeeScriptTokenTypes.MINUS; }
  "*"                         { return CoffeeScriptTokenTypes.MATH; }
  "%"                         { return CoffeeScriptTokenTypes.MATH; }
  "/" / [ ]+                  { return CoffeeScriptTokenTypes.MATH; }

  "///"                       { yybegin(YYHEREGEX);
                                return CoffeeScriptTokenTypes.HEREGEX_START; }

  "/" / [^ \n\r]+             { yybegin(YYREGEX);
                                return CoffeeScriptTokenTypes.REGEX_START; }

  {BLOCK_COMMENT}             { return CoffeeScriptTokenTypes.BLOCK_COMMENT; }
  {LINE_COMMENT}              { return CoffeeScriptTokenTypes.LINE_COMMENT; }

  {TERMINATOR}                { return CoffeeScriptTokenTypes.TERMINATOR; }
  {WHITE_SPACE}               { return CoffeeScriptTokenTypes.WHITE_SPACE; }
}

<YYIDENTIFIER, YYNUMBER> {
  "."                         { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.DOT; }

  ":"                         { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.COLON; }

  "::"                        { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.PROTOTYPE; }

  ","                         { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.COMMA; }

  "["                         { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.BRACKET_START; }

  "]"                         { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.BRACKET_END; }

  ")"                         { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.PARENTHESIS_END; }

  {TERMINATOR}                { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.TERMINATOR; }

  {WHITE_SPACE}               { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.WHITE_SPACE; }
}

<YYIDENTIFIER> {
  "?"                         { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.EXIST; }

  "..."                       { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.SPLAT; }

  "("                         { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.PARENTHESIS_START; }
}

<YYNUMBER> {
  ".."                        { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.RANGE; }

  "..."                       { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.RANGE; }
}

<YYDOUBLEQUOTESTRING> {
  \"                          { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.STRING_LITERAL; }

  {DOUBLE_QUOTE_STRING}       { pushBackAndState("#{", YYINTERPOLATION);
                                if (yytext().length() != 0) {
                                  return CoffeeScriptTokenTypes.STRING;
                                }
                              }

  {TERMINATOR}                { return CoffeeScriptTokenTypes.TERMINATOR; }
}

<YYSINGLEQUOTESTRING> {
  \'                          { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.STRING_LITERAL; }

  {SINGLE_QUOTE_STRING}       { return CoffeeScriptTokenTypes.STRING; }
  {TERMINATOR}                { return CoffeeScriptTokenTypes.TERMINATOR; }
}

<YYJAVASCRIPT> {
  "`"                         { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.JAVASCRIPT_LITERAL; }

  {JAVASCRIPT}                { return CoffeeScriptTokenTypes.JAVASCRIPT; }
}

<YYSINGLEQUOTEHEREDOC> {
  "'''"                       |
  "'''" / [^\n\r]+            { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.HEREDOC_END; }

  [^\n\r]+                    { pushBackTo("'''");
                                return CoffeeScriptTokenTypes.HEREDOC; }

  {TERMINATOR}                { return CoffeeScriptTokenTypes.TERMINATOR; }
}

<YYDOUBLEQUOTEHEREDOC> {
  "\"\"\""                    |
  "\"\"\"" / [^\n\r]+         { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.HEREDOC_END; }

  [^\n\r]+                    { if (!pushBackAndState("#{", YYINTERPOLATION)) {
                                  pushBackTo("\"\"\"");
                                }
                                if (yytext().length() != 0) {
                                  return CoffeeScriptTokenTypes.HEREDOC;
                                }
                              }

  {TERMINATOR}                { return CoffeeScriptTokenTypes.TERMINATOR; }
}

<YYREGEX, YYHEREGEX> {
  "("                         { return CoffeeScriptTokenTypes.REGEX_PARENTHESIS_START; }
  ")"                         { return CoffeeScriptTokenTypes.REGEX_PARENTHESIS_END; }
  "{"                         { return CoffeeScriptTokenTypes.REGEX_BRACE_START; }
  "}"                         { return CoffeeScriptTokenTypes.REGEX_BRACE_END; }

  [\\][^\n\r]                 |
  [\\][0-8]{1,3}              |
  [\\]x[0-9a-fA-F]{1,2}       |
  [\\]u[0-9a-fA-F]{1,4}       { return CoffeeScriptTokenTypes.REGEX_ESCAPE; }
}

<YYREGEX> {
  "/"                         |
  "/" / [imgy]{1,4}           { yybegin(YYREGEXFLAG);
                                return CoffeeScriptTokenTypes.REGEX_END;
                              }

  "["                         { characterClassType = CoffeeScriptTokenTypes.REGEX;
                                pushStateAndBegin(YYREGEXCHARACTERCLASS);
                                return CoffeeScriptTokenTypes.REGEX_BRACKET_START; }


  {REGEX}                     { return CoffeeScriptTokenTypes.REGEX; }
}

<YYHEREGEX> {
  "///"                       |
  "///" / [^\n\r]+            { yybegin(YYREGEXFLAG);
                                return CoffeeScriptTokenTypes.HEREGEX_END; }

  [^\[\]\{\}\(\)#\n\r]+       { pushBackTo("///");
                                if (yytext().length() != 0) {
                                  return CoffeeScriptTokenTypes.HEREGEX;
                                }
                              }

  "#{"                        { yypushback(2);
                                pushStateAndBegin(YYINTERPOLATION); }

  "["                         { characterClassType = CoffeeScriptTokenTypes.HEREGEX;
                                pushStateAndBegin(YYREGEXCHARACTERCLASS);
                                return CoffeeScriptTokenTypes.REGEX_BRACKET_START; }


  {LINE_COMMENT}              { return CoffeeScriptTokenTypes.LINE_COMMENT; }
  {TERMINATOR}                { return CoffeeScriptTokenTypes.TERMINATOR; }
}

<YYREGEXFLAG> {
  [imgy]{1,4}                 { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.REGEX_FLAG; }

  [ .\[\n\r]                  { yybegin(YYINITIAL);
                                yypushback(1);
                              }
}

<YYREGEXCHARACTERCLASS> {
  "]"                         { popState();
                                return CoffeeScriptTokenTypes.REGEX_BRACKET_END; }

  [\\][^\n\r]                 { return CoffeeScriptTokenTypes.REGEX_ESCAPE; }

  [^\\\]\n\r]+                { return characterClassType; }
}

<YYINTERPOLATION> {
  "#{"                        { pushStateAndBegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.INTERPOLATION_START; }

  "}"                         { popState();
                                return CoffeeScriptTokenTypes.INTERPOLATION_END; }
}

.                             { yybegin(YYINITIAL);
                                return CoffeeScriptTokenTypes.BAD_CHARACTER; }
