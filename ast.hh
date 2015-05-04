#ifndef AST_HH
#define AST_HH
#include <vector>
#include <map>

class Exp;
class Const;
class Binop;
// class Varname;
// class Assign;
class Scope;
class Driver;
class Visitor;
class PrettyPrinter;
class Evaluator;


class Exp {
public:

	Exp() {};
	Exp(const Exp& exp) {};

	virtual ~Exp() {};
	virtual int accept(Visitor& v) const = 0;

};

class Const: public Exp {
public:

	int val_;

	Const(int val)
			: val_(val) {}

	virtual int accept(Visitor& v) const;

};

class Binop: public Exp {
public:

	char oper_;
	Exp* lhs_;
	Exp* rhs_;

	Binop(char oper, Exp* lhs, Exp* rhs)
			: Exp(), oper_(oper), lhs_(lhs), rhs_(rhs) {}

	~Binop() {
		delete lhs_;
		delete rhs_;
	}

	virtual int accept(Visitor& v) const;

};

// class Varname: public Exp {
// public:

// 	char[20] nom_;

// 	Varname(char oper, Exp* lhs, Exp* rhs)
// 			: Exp(), nom_(nom) {}

// 	~Varname() {
// 		delete nom_;
// 	}

// 	virtual int accept(Visitor& v) const;

// };

// class Assign: public Exp {
// public:

// 	Varname* lhs_;
// 	Exp* rhs_;

// 	Binop(Varname* lhs, Exp* rhs)
// 			: Exp(), lhs_(lhs), rhs_(rhs) {}

// 	~Assign() {
// 		delete lhs_;
// 		delete rhs_;
// 	}

// 	virtual int accept(Visitor& v) const;

// };


class Scope: public Exp {
public:

	// int level_;
	// std::vector<Exp*> tree_;
	// std::map<Varname, Exp*> map_;

	char type_;
	Exp* cond_;
	Exp* content_;

	// Scope* upper_;

	Scope() : Exp() {}

	Scope(char type, Exp* cond, Exp* content)
			: Exp(), type_(type), cond_(cond), content_(content) {}

	~Scope() {
		delete cond_;
		delete content_;
	}

	// void addExp(Exp* exp) {
	// 	tree_.push_back(exp);
	// }

	// void assign(Varname varname, Exp* exp) {
	// 	this.map_[varname] = exp;
	// }

	// Exp* get(Varname varname) {
	// 	if (this.map_.find(varname) == this.map_.end() && this.isGlobal) {
	// 		if (this.isGlobal) {
	// 			return 777;
	// 		}
	// 		return upper_.map_.get(varname);
	// 	}
	// 	return this.map_[varname];
	// }


	virtual int accept(Visitor& v) const;

};


class Driver {
public:

	Scope* currentScope_;

	Driver(Scope* mainScope)
			: currentScope_(mainScope) {}

	Exp* makeBinop(char oper, Exp* lhs, Exp* rhs) {
		return new Binop(oper, lhs, rhs);
	}

	Exp* makeConst(int value) {
		return new Const(value);
	}

	Exp* makeScope(char type, Exp* cond, Exp* content) {
		return new Scope(type, cond, content);
	}

};




class Visitor {
public:

	Visitor(){};
	virtual ~Visitor(){};

	virtual int visitBinop(const Binop& exp) = 0;
	virtual int visitConst(const Const& exp) = 0;
	virtual int visitScope(const Scope& exp) = 0;
};


class PrettyPrinter : public Visitor {
public:

	std::ostream& ostr_;

	PrettyPrinter(std::ostream& ostr)
			: ostr_(ostr) {}

	virtual int visitBinop(const Binop& e) {
		ostr_ << '(';
		e.lhs_->accept(*this);

		char oper = e.oper_;
		if(oper == '=') {
			ostr_ << "==";
		} else {
			ostr_ << oper;
		}

		e.rhs_->accept(*this);
		ostr_ << ')';
		return 0;
	}

	virtual int visitConst(const Const& e) {
		ostr_ << e.val_;
		return 0;
	}

	virtual int visitScope(const Scope& e) {
		if (e.type_ == 'w') {
			ostr_ << "while(";
			ostr_ << e.cond_->accept(*this) << ") ";
		}

		if (e.type_ == 'i') {
			ostr_ << "if(";
			ostr_ << e.cond_->accept(*this) << ") ";
		}

		ostr_ << "{\n";
		ostr_ << e.content_->accept(*this);
		ostr_ << "\n}\n";

		return 0;
	}

};


class Evaluator : public Visitor {
public:

	Evaluator() {}

	virtual int visitBinop(const Binop& e) {

		if (e.oper_ == '+')
			return e.lhs_->accept(*this) + e.rhs_->accept(*this);

		if (e.oper_ == '-')
			return e.lhs_->accept(*this) - e.rhs_->accept(*this);

		if (e.oper_ == '*')
			return e.lhs_->accept(*this) * e.rhs_->accept(*this);

		if (e.oper_ == '/') {
			int divby = e.rhs_->accept(*this);
			if (!divby) {
				return 9999999;
			}
			return e.lhs_->accept(*this) / divby;
		}

		if (e.oper_ == '&')
			return e.lhs_->accept(*this) && e.rhs_->accept(*this);

		if (e.oper_ == '|')
			return e.lhs_->accept(*this) || e.rhs_->accept(*this);

		if (e.oper_ == '=') {
			return e.lhs_->accept(*this) == e.rhs_->accept(*this);
		}

		return -1;
		
	}

	virtual int visitConst(const Const& e){
		return e.val_;
	}

	virtual int visitScope(const Scope& e){

		if (e.type_ == 'i') {
			if (e.cond_->accept(*this) == 1) {
				return e.content_->accept(*this);
			}
		}

		if (e.type_ == 'n') {
			return e.content_->accept(*this);
		}

		return 0;
	}

};

inline int Const::accept(Visitor& v) const{
	return v.visitConst(*this);
}

inline int Binop::accept(Visitor& v) const{
	return v.visitBinop(*this);
}

inline int Scope::accept(Visitor& v) const{
	return v.visitScope(*this);
}

inline std::ostream& operator<<(std::ostream& o, Exp &e){
	PrettyPrinter printer(o);
	e.accept(printer);
	return o;
}


#endif